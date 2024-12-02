provider "aws" {
  region = var.region
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_security_group"
  description = "Allow traffic on ports 22 and 8080"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.82.37.98/32"] # Replace with your actual public IP
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all IPs for Jenkins web access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkinskp"
  public_key = file("/Users/jeremysmith/.ssh/jenkinskp.pub") # Path to your existing public SSH key (create one if needed)
}

resource "aws_instance" "jenkins" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.jenkins_sg.name]

  # Configure the instance to use a public IP
  associate_public_ip_address = true

 
  user_data = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y java-11-openjdk
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
    sudo yum install -y jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
  EOT

  tags = {
    Name = "JenkinsServer"
  }
}

# Create a unique string for the bucket name
resource "random_string" "unique_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create the S3 bucket
resource "aws_s3_bucket" "jenkins_artifacts" {
  bucket = "jenkins-artifacts-${random_string.unique_suffix.result}" # Ensures the bucket name is unique
}

# Block public access settings using aws_s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "jenkins_artifacts_block" {
  bucket = aws_s3_bucket.jenkins_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "instance_public_ip" {
  value = aws_instance.jenkins.public_ip
}


