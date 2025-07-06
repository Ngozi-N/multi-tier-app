variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Name for the project, used as a prefix for resources."
  type        = string
  default     = "multi-tier-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db_subnets_cidr" {
  description = "List of CIDR blocks for database subnets."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

# EC2 instances
variable "instance_type" {
  description = "EC2 instance type for application servers and Jenkins/Monitoring."
  type        = string
  default     = "t3.medium" # Consider t3.large for Jenkins/Monitoring
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Ubuntu 22.04 LTS HVM recommended)."
  type        = string
  default     = "ami-044415bb13eee2391" # Replace with a valid Ubuntu 22.04 LTS AMI for your region
}

variable "key_name" {
  description = "The name of the EC2 Key Pair to use for SSH access."
  type        = string
  default     = "mytest_keypair"
}

# RDS variables
variable "db_instance_class" {
  description = "DB instance class for RDS."
  type        = string
  default     = "db.t3.micro" # For testing, use a small instance.
}

variable "db_name" {
  description = "Name of the database."
  type        = string
  default     = "webappdb"
}

variable "db_username" {
  description = "Username for the database."
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Password for the database."
  type        = string
  sensitive   = true # Mark as sensitive to prevent logging
}