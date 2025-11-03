# Setup Key Pair
resource "aws_key_pair" "this_keypair" {
  key_name   = "my-ec2-instance-keypair"
  public_key = file("ec2_keys/aws-my-public-instance-public-key.pub")
}

# Setup EC" instance
resource "aws_instance" "local_vm_server" {
  ami           = var.ec2_instance_ami
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.this_subnet.id
  vpc_security_group_ids = [aws_security_group.this_sg.id]
  key_name      = aws_key_pair.this_keypair.key_name
  associate_public_ip_address =   true

  tags = {
    Name = var.ec2_instance_name
  }
}
