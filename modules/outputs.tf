output "ec2_public_ip" {
  value = aws_instance.myapp_ec2.public_ip
}