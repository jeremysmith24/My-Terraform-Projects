# AWS Region
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "CustomVPC-tf"
}

# Public Subnet Configuration
variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_1_tf" {
  description = "Name for the first public subnet"
  type        = string
  default     = "PublicSubnet1-tf"
}

variable "public_subnet_2_tf" {
  description = "Name for the second public subnet"
  type        = string
  default     = "PublicSubnet2-tf"
}

# Private Subnet CIDR
variable "private_subnet_1_tf" {
  description = "Name for the first private subnet"
  type        = string
  default     = "PrivateSubnet1-tf"
}

variable "private_subnet_2_tf" {
  description = "Name for the second private subnet"
  type        = string
  default     = "PrivateSubnet2-tf"
}

# Private Subnet Configuration
variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
  default     = "10.0.4.0/24"
}

# Instance Configuration
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0e2c8caa4b6378d8c" # Replace with a valid AMI ID
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 5
}

# Security Group Configuration
variable "internet_gateway_name" {
  description = "Name for the Internet Gateway"
  type        = string
  default     = "InternetGateway-tf"
}

variable "nat_gateway_name" {
  description = "Name for the NAT Gateway"
  type        = string
  default     = "NatGateway-tf"
}

variable "nat_eip_name" {
  description = "Name for the NAT Elastic IP"
  type        = string
  default     = "NatEIP-tf"
}

# ALB Configuration
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "web-alb-tf"
}

variable "alb_listening_port" {
  description = "Port on which the ALB listens"
  type        = number
  default     = 80
}

variable "alb_security_group_name" {
  description = "Security group name for the ALB"
  type        = string
  default     = "alb-tf-sg"
}

# Variable for the S3 bucket name used for Terraform state
variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
  default     = "my-tfstate-bucket-24"
}