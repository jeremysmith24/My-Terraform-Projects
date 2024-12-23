resource "aws_default_vpc" "default-vpc" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_vpc" "default-vpc" {
  id = var.default_vpc
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.default_vpc]
  }
}

# Retrieve all Subnet IDs in the Default VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default-vpc.id]
  }
}

# Creating subnets for the default VPC
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b"

  tags = {
    Name = "Default subnet for us-east-1b"
  }
}

# Declare the AZ data source
data "aws_availability_zones" "available" {
  state = "available"
}

# Creating an Autoscaling Group
resource "aws_autoscaling_group" "terraform_asg" {
  name               = "my-terraform-asg"
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity
  availability_zones = var.availability_zones

  launch_template {
    id      = aws_launch_template.launch-asg.id
    version = "$Latest"
  }

  # Tagging the ASG for better indentification
  tag {
    key                 = "Name"
    value               = "terraform-asg-instance"
    propagate_at_launch = true
  }
}

# Creating a launch template for the ASG
resource "aws_launch_template" "launch-asg" {
  name          = "my-launch-asg"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key
  user_data     = base64encode(file("install_apache.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "MyLaunchASGInstance"
    }
  }
}


data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:Name"
    values = ["my-terraform-asg"] # Matches the ASG instance tag
  }

  instance_state_names = ["running"]
}