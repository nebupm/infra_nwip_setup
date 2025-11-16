#########################################################
#This will create a VPC with public subnet, an EC2 instance with an attached EBS volume using Terraform.

#########################################################
# TERRAFORM + PROVIDER
#########################################################
terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

#########################################################
# VARIABLES
#########################################################
# Define the region for AWS resources
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}
# Define the region for AWS resources
variable "aws_profile" {
  description = "The AWS profile to use for running the code"
  type        = string
  default     = "default"
}

# VPC and Networking Variables
variable "vpc_name" {
  type        = string
  description = "VPC Name that use network with public subnet"
  default     = "main-vpc-nwip"
}
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR values"
  default     = "10.0.0.0/16"
}

variable "igw_name" {
  type        = string
  description = "Internet Gateway Name"
  default     = "igw"
}

# EC2 Instance Variables
variable "linux_instance_type" {
  type        = string
  description = "EC2 Instance Type"
  default     = "t3.nano"
}
variable "linux_instance_ami" {
  type        = string
  description = "EC2 Instance Amazon Linux 2023 AMI"
  #default     = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  # Corresponds to Amazon Linux 2023 in eu-west-2 al2023-ami-2023.9.20251027.0-kernel-6.1-x86_64
  default = "ami-024294779773cf91a"
}
variable "linux_instance_name" {
  type        = string
  description = "Name of the EC2 instance"
  default     = "linux_vm_nwip"
}
variable "ebs_volume_size_gb" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 4
}

#########################################################
# NETWORK RESOURCES
#########################################################
# Setup main vpc
resource "aws_vpc" "this_vpc" {
  cidr_block = var.vpc_cidr
  tags       = { Name = var.vpc_name }
}

# Setup main subnet
resource "aws_subnet" "this_subnet" {
  vpc_id     = aws_vpc.this_vpc.id
  cidr_block = "10.0.0.0/24"
  tags       = { Name = "${var.vpc_name}-public-subnet" }
}

resource "aws_internet_gateway" "this_igw" {
  vpc_id = aws_vpc.this_vpc.id
  tags   = { Name = "${var.vpc_name}-${var.igw_name}" }
}

resource "aws_route_table" "this_route_table" {
  vpc_id = aws_vpc.this_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this_igw.id
  }
  tags = { Name = "${var.vpc_name}-${var.igw_name}-rt" }
}

resource "aws_route_table_association" "this_route_table_association" {
  subnet_id      = aws_subnet.this_subnet.id
  route_table_id = aws_route_table.this_route_table.id
}

resource "aws_security_group" "this_sg" {
  name        = "${var.vpc_name}-ec2-inst-sg"
  description = "Security group for ${var.vpc_name}"
  vpc_id      = aws_vpc.this_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.16.60.106/32"]
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["82.16.60.106/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.vpc_name}-ec2-inst-sg" }
}
#########################################################
# EC2 INSTANCE
#########################################################
# Setup Key Pair
resource "aws_key_pair" "this_keypair" {
  key_name   = "my-ec2-instance-keypair"
  public_key = file("../../ec2_all_keys/aws-ec2-linux-instance-public-key.pub")
}

# Setup EC" instance
resource "aws_instance" "local_vm_server" {
  ami                         = var.linux_instance_ami
  instance_type               = var.linux_instance_type
  subnet_id                   = aws_subnet.this_subnet.id
  vpc_security_group_ids      = [aws_security_group.this_sg.id]
  key_name                    = aws_key_pair.this_keypair.key_name
  associate_public_ip_address = true
  user_data                   = <<-EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x
sleep 30
retry=3
while [[ $retry > 0 ]]; do
  # Detect the root NVMe device dynamically
  ROOT_NAME=$(lsblk -no PKNAME $(findmnt / -o SOURCE -n))
  # Detect secondary EBS NVMe volume
  DEVICE=$(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print $1}' | grep nvme | grep -v "$ROOT_NAME" | head -n 1)
  if [[ -n $DEVICE ]]; then 
    DEVICE="/dev/$DEVICE"
    # Create filesystem only if none exists
    if ! blkid $DEVICE; then
      mkfs -t xfs $DEVICE
    fi
    mkdir -p /mnt/data
    mount $DEVICE /mnt/data
    uuid=$(blkid -s UUID -o value $DEVICE)
    grep $uuid /etc/fstab > /dev/null
    if [[ $? -ne 0 ]]; then
      echo "UUID=$uuid /mnt/data xfs defaults,nofail 0 2" >> /etc/fstab
      chown ec2-user:ec2-user /mnt/data
      chmod 775 /mnt/data
      ## To Survive Reboot.
      echo "chown ec2-user:ec2-user /mnt/data" >> /etc/rc.local
      echo "chmod 775 /mnt/data" >> /etc/rc.local
      chmod +x /etc/rc.local
    fi
    break
  else
    sleep 30
    retry=$((retry-1))
  fi
done
EOF
  tags                        = { Name = var.linux_instance_name }
}

resource "aws_ebs_volume" "data_volume" {
  availability_zone = aws_instance.local_vm_server.availability_zone
  size              = var.ebs_volume_size_gb
  type              = "gp3"
  tags              = { Name = "${var.linux_instance_name}-data" }
}

resource "aws_volume_attachment" "attach_data" {
  device_name  = "/dev/sdf"
  volume_id    = aws_ebs_volume.data_volume.id
  instance_id  = aws_instance.local_vm_server.id
  force_detach = true
}



# EC2 Instance details
output "ec2_instance_details" {
  value = {
    id            = aws_instance.local_vm_server.id
    name          = aws_instance.local_vm_server.tags.Name
    public_ip     = aws_instance.local_vm_server.public_ip
    ami           = aws_instance.local_vm_server.ami
    instance_type = aws_instance.local_vm_server.instance_type
  }
}