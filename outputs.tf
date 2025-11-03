# Outputs for the resource created.
output "vpc_id" {
  value = {
    id = aws_vpc.this_vpc.id
    name = aws_vpc.this_vpc.tags.Name
    cide = aws_vpc.this_vpc.cidr_block
  }
}

output "subnet_details" {
  value = {
    name = aws_subnet.this_subnet.tags.Name
    id   = aws_subnet.this_subnet.id
    cidr = aws_subnet.this_subnet.cidr_block
    }
}

output "ec2_instance_details" {
  value = {
    id = aws_instance.local_vm_server.id
    name = aws_instance.local_vm_server.tags.Name
    public_ip = aws_instance.local_vm_server.public_ip
    ami = aws_instance.local_vm_server.ami
    instance_type = aws_instance.local_vm_server.instance_type 
  }
}