# Provider configuration
provider "aws" {
  region = var.region
}

# Create a Custom VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Create Public Subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_1_tf
  }
}

# Create Public Subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_2_tf
  }
}

# Create Private Subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = var.private_subnet_1_tf
  }
}

# Create Private Subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = var.private_subnet_2_tf
  }
}

# Create Internet Gateway for Public Subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

# Create NAT Gateway for Private Subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = var.nat_eip_name
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = var.nat_gateway_name
  }
}

# Create Route Tables for Public and Private Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create Public Route Associations
resource "aws_route_table_association" "association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

# Create Private Route Associations
resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# main.tf
module "iam" {
  source = "/Users/jeremysmith/My-Terraform-Projects/modules/iam"  # Path to the IAM module
}

# Terraform Data Block - Lookup Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["211125607489"]
}

# Create Launch Configuration for Auto Scaling Group
resource "aws_launch_configuration" "asg_launch_config" {
  name                 = "asg-launch-config"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  iam_instance_profile = module.iam.terraform_instance_profile
  user_data            = file("install_apache.sh")
  security_groups      = [aws_security_group.asg_sg.id]
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name                      = "autoscaling_group_tf"
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  launch_configuration      = aws_launch_configuration.asg_launch_config.id
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.web_target_group.arn]

  tag {
    key                 = "Name"
    value               = "AutoScalingInstance"
    propagate_at_launch = true
  }
}

# Create Load Balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false
}

# Create Target Group for ALB
resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id

  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "WebTargetGroupTF"
  }
}

# Create Listener for the ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

# Create Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  description = "Allow inbound HTTP traffic to the ALB"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Security Group for ASG Instances
resource "aws_security_group" "asg_sg" {
  name_prefix = "asg-sg-"
  description = "Allow inbound HTTP traffic from ALB only"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# S3 Bucket for storing Terraform state (for backend configuration)
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Production"
  }
}

# S3 Bucket for Static Website Hosting (using ACL and Versioning resources separately)
resource "aws_s3_bucket" "static_website" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "Static Website Bucket"
    Environment = "Production"
  }
}

# Enable versioning for the Static Website S3 bucket
resource "aws_s3_bucket_versioning" "static_website_versioning" {
  bucket = aws_s3_bucket.static_website.id

  versioning_configuration {
    status = "Enabled" # Enable versioning for the bucket
  }
}

# Upload the index.html file to the S3 bucket to serve the static website
resource "aws_s3_object" "website_index" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "index.html"                                                                         # The key for the uploaded file (S3 object name)
  source = "/Users/jeremysmith/My-Terraform-Projects/Terraform_project_2/index.html"            # Replace with the path to your local file
  etag   = md5(file("/Users/jeremysmith/My-Terraform-Projects/Terraform_project_2/index.html")) # Calculate the MD5 checksum for the file

  acl = "public-read" # Make the file publicly readable

  content_type = "text/html" # Specify the content type for HTML
}