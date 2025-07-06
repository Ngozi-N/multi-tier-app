# terraform/iam.tf
# IAM Role for EC2 instances to allow them to access AWS services (e.g., S3 for artifacts, SSM)
resource "aws_iam_role" "app_instance_role" {
  name = "${var.project_name}-app-instance-role"

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

  tags = { Name = "${var.project_name}-app-instance-role" }
}

# Attach S3 Read-Only policy to the role (for fetching artifacts/scripts)
resource "aws_iam_role_policy_attachment" "app_s3_policy" {
  role       = aws_iam_role.app_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" # For pulling artifacts if needed
}

# Create an Instance Profile to associate the IAM role with EC2 instances
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "${var.project_name}-app-instance-profile"
  role = aws_iam_role.app_instance_role.name
}