resource "aws_instance" "monitoring_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id # Place Monitoring in a public subnet
  key_name      = var.key_name
  vpc_security_group_ids = [
    aws_security_group.ssh_sg.id,
    aws_security_group.monitoring_sg.id
  ]
  associate_public_ip_address = true

  user_data = file("${path.module}/user-data/monitoring_setup.sh")

  tags = {
    Name = "${var.project_name}-monitoring-server"
    Tier = "Monitoring"
  }
}