# Outputs for the resource created.
output "vpc_id" {
  value = {
    id   = aws_vpc.this_vpc.id
    name = aws_vpc.this_vpc.tags.Name
    cide = aws_vpc.this_vpc.cidr_block
  }
}
# Subnet details
output "subnet_details" {
  value = {
    name = aws_subnet.this_subnet.tags.Name
    id   = aws_subnet.this_subnet.id
    cidr = aws_subnet.this_subnet.cidr_block
  }
}

