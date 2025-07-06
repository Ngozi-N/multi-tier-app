# Backend Launch Template
resource "aws_launch_template" "backend_lt" {
  name_prefix   = "${var.project_name}-backend-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [
    aws_security_group.ssh_sg.id,
    aws_security_group.backend_instance_sg.id,
    aws_security_group.monitoring_sg.id # Allow monitoring server to scrape backend
  ]
  iam_instance_profile {
    name = aws_iam_instance_profile.app_instance_profile.name
  }
  user_data = base64encode(file("${path.module}/user-data/app_instance_setup.sh")) # For Docker, Node Exporter, etc.

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-backend-instance"
      Tier = "Backend"
    }
  }
}

# Backend Auto Scaling Group
resource "aws_autoscaling_group" "backend_asg" {
  name                      = "${var.project_name}-backend-asg"
  vpc_zone_identifier       = [for s in aws_subnet.private : s.id]
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.backend_tg.arn]
  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest" # Corrected to "$Latest"
  }
}