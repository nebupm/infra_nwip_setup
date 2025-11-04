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
  default     = "main-vpc"
}
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR values"
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  type        = string
  description = "Subnet Name"
  default     = "public_subnet"
}
variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR values"
  default     = "10.0.0.0/24"
}

variable "igw_name" {
  type        = string
  description = "Internet Gateway Name"
  default     = "main-igw"
}

# EC" Instance Variables
variable "ec2_instance_type" {
  type        = string
  description = "EC2 Instance Type"
  default     = "t3.nano"
}
variable "ec2_instance_ami" {
  type        = string
  description = "EC2 Instance AMI"
  #default     = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  # Corresponds to Amazon Linux 2023 in eu-west-2 al2023-ami-2023.9.20251027.0-kernel-6.1-x86_64
  default = "ami-024294779773cf91a"
}
variable "ec2_instance_name" {
  type        = string
  description = "Name of the EC2 instance"
  default = "myec2_instance"
}
