# Local Variables
locals {
  http_security_group_name = "${var.vpc_name}-http-sg"
}


# Setup main vpc
resource "aws_vpc" "this_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# Setup main subnet
resource "aws_subnet" "this_subnet" {
  vpc_id     = aws_vpc.this_vpc.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = var.subnet_name
  }
}

resource "aws_internet_gateway" "this_igw" {
  vpc_id = aws_vpc.this_vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "this_route_table" {
  vpc_id = aws_vpc.this_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this_igw.id
  }
  tags = {
    Name = "${var.vpc_name}-${var.igw_name}-route-table"
  }
}

resource "aws_route_table_association" "this_route_table_association" {
  subnet_id      = aws_subnet.this_subnet.id
  route_table_id = aws_route_table.this_route_table.id
}

resource "aws_security_group" "this_sg" {
  name        = local.http_security_group_name
  description = "Security group for ${var.vpc_name}"
  vpc_id      = aws_vpc.this_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = local.http_security_group_name
  }
}