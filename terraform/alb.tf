resource "aws_lb" "frontend_alb" {
  name               = "${var.project_name}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in aws_subnet.public : s.id]

  tags = {
    Name = "${var.project_name}-frontend-alb"
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "${var.project_name}-frontend-tg"
  port        = 80 # Or the port your frontend Nginx/app serves on
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-frontend-tg"
  }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    type             = "forward"
  }
}

resource "aws_lb" "backend_alb" {
  name               = "${var.project_name}-backend-alb"
  internal           = true # Internal ALB for backend
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_instance_sg.id] # Backend instances SG can ingress from here
  subnets            = [for s in aws_subnet.private : s.id] # Private subnets

  tags = {
    Name = "${var.project_name}-backend-alb"
  }
}

resource "aws_lb_target_group" "backend_tg" {
  name        = "${var.project_name}-backend-tg"
  port        = 3001 # Or the port your backend API serves on
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health" # Example health check endpoint
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-backend-tg"
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 3001
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    type             = "forward"
  }
}