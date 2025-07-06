resource "aws_iam_role" "jenkins_role" {
  name = "${var.project_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-jenkins-role"
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_s3_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # For artifact storage, etc.
}

resource "aws_iam_role_policy_attachment" "jenkins_ec2_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess" # For managing instances/ASGs
}

resource "aws_iam_role_policy_attachment" "jenkins_rds_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess" # If Jenkins needs to interact with RDS
}

resource "aws_iam_role_policy_attachment" "jenkins_alb_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess" # For managing ALBs
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

resource "aws_instance" "jenkins_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id # Place Jenkins in a public subnet
  key_name      = var.key_name
  vpc_security_group_ids = [
    aws_security_group.ssh_sg.id,
    aws_security_group.jenkins_sg.id,
    aws_security_group.monitoring_sg.id # Allow monitoring server to scrape Jenkins
  ]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name

  user_data = file("${path.module}/user-data/jenkins_setup.sh")

  tags = {
    Name = "${var.project_name}-jenkins-server"
    Tier = "Management"
  }
}