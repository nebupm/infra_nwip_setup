#########################################################
#This will create a VPC, Subnets, IGW, Routing tables and Security Groups.
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
  description = "VPC Name"
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

#########################################################
# NETWORK RESOURCES
#########################################################
# Setup main vpc
resource "aws_vpc" "this_vpc" {
  cidr_block = var.vpc_cidr
  tags       = { Name = var.vpc_name }
}

# Setup main subnet
resource "aws_subnet" "this_public_subnet" {
  vpc_id     = aws_vpc.this_vpc.id
  cidr_block = "10.0.0.0/24"
  tags       = { Name = "${var.vpc_name}-public-subnet" }
}

resource "aws_internet_gateway" "this_igw" {
  vpc_id = aws_vpc.this_vpc.id
  tags   = { Name = "${var.vpc_name}-igw" }
}

resource "aws_route_table" "this_public_route_table" {
  vpc_id = aws_vpc.this_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this_igw.id
  }
  tags = { Name = "${var.vpc_name}-public-rt" }
}

resource "aws_route_table_association" "this_public_route_table_association" {
  subnet_id      = aws_subnet.this_public_subnet.id
  route_table_id = aws_route_table.this_public_route_table.id
}

resource "aws_security_group" "this_sg" {
  name        = "${var.vpc_name}-ec2-inst-sg"
  description = "Security group for EC2 Instances in ${var.vpc_name}"
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
# VPC and SUBNETS
#########################################################

output "vpc_name" {
  description = "Details of the main VPC"
  value       = aws_vpc.this_vpc.tags.Name
}

output "public_subnet_name" {
  description = "Details of the main public subnet"
  value       = aws_subnet.this_public_subnet.tags.Name
}
