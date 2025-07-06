resource "aws_security_group" "ssh_sg" {
  name        = "${var.project_name}-ssh-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For production, restrict this to your IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-ssh-sg" }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Allow Jenkins inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080 # Jenkins default HTTP port
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For production, restrict this to your IP or specific CIDR
  }
  # Allow SSH from SSH SG
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.ssh_sg.id]
  }
  # Allow Prometheus to scrape Node Exporter from monitoring server
  ingress {
    from_port        = 9100 # Node Exporter
    to_port          = 9100
    protocol         = "tcp"
    security_groups = [aws_security_group.monitoring_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-jenkins-sg" }
}

resource "aws_security_group" "monitoring_sg" {
  name        = "${var.project_name}-monitoring-sg"
  description = "Allow Prometheus/Grafana inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3000 # Grafana default HTTP port
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Restrict access
  }
  ingress {
    from_port   = 9090 # Prometheus default HTTP port
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Restrict access
  }
   # Allow SSH from SSH SG
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.ssh_sg.id]
  }
  # Allow Prometheus to scrape metrics from app/frontend/backend/jenkins instances
#   ingress {
#     from_port        = 9100 # Node Exporter
#     to_port          = 9100
#     protocol         = "tcp"
#     security_groups = [
#       aws_security_group.frontend_instance_sg.id,
#       aws_security_group.backend_instance_sg.id,
#       aws_security_group.jenkins_sg.id
#     ]
#   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-monitoring-sg" }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP/HTTPS traffic to ALBs"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Add HTTPS if you plan to use it (requires ACM certificate)
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-alb-sg" }
}

resource "aws_security_group" "frontend_instance_sg" {
  name        = "${var.project_name}-frontend-instance-sg"
  description = "Allow traffic from ALB to Frontend instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80   # Or your frontend app port (e.g., 3000 for React dev server, 80 for Nginx)
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Only from ALB
  }
  # Allow SSH from SSH SG
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.ssh_sg.id]
  }
  # Allow Prometheus to scrape Node Exporter
  ingress {
    from_port        = 9100 # Node Exporter
    to_port          = 9100
    protocol         = "tcp"
    security_groups = [aws_security_group.monitoring_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound to internet (for pulling Docker images, etc.)
  }
  tags = { Name = "${var.project_name}-frontend-instance-sg" }
}

resource "aws_security_group" "backend_instance_sg" {
  name        = "${var.project_name}-backend-instance-sg"
  description = "Allow traffic from Frontend instances (ALB) to Backend instances, and Backend to DB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3001 # Or your backend app port (e.g., 3001 for Node.js API)
    to_port     = 3001
    protocol    = "tcp"
    security_groups = [aws_security_group.frontend_instance_sg.id] # Only from Frontend instances
  }
  # Allow SSH from SSH SG
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.ssh_sg.id]
  }
  # Allow Prometheus to scrape Node Exporter
  ingress {
    from_port        = 9100 # Node Exporter
    to_port          = 9100
    protocol         = "tcp"
    security_groups = [aws_security_group.monitoring_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound to internet
  }
  tags = { Name = "${var.project_name}-backend-instance-sg" }
}

resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow traffic from Backend instances to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432 # PostgreSQL default port
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.backend_instance_sg.id] # Only from Backend instances
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-db-sg" }
}