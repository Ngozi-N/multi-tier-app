resource "aws_db_instance" "main_db" {
  allocated_storage    = 20
  db_name              = var.db_name
  engine               = "postgres" # Or "mysql"
  engine_version       = "14.12"     # Choose a compatible version
  instance_class       = var.db_instance_class
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres14" # Adjust for MySQL or other DB
  skip_final_snapshot  = true # Set to false in production!
  publicly_accessible  = false # Crucial for security
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.project_name}-rds-db"
  }
}