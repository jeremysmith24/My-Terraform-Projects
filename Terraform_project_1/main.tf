resource "aws_instance" "jenkins" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [aws_security_group.jenkins_sg.name]
  associate_public_ip_address = true
  user_data                   = file("install_jenkins.sh")
  tags = {
    Name = "JenkinsServer"
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow traffic on ports 22 and 8080"

  ingress {
    description = "Allow SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 8080 Traffic"
    from_port   = 8080
    to_port     = 8080
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

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkinskp"
  public_key = file("/Users/jeremysmith/.ssh/jenkinskp.pub") # Path to your existing public SSH key (create one if needed)
}

# Create a unique string for the bucket name
resource "random_string" "unique_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create the S3 bucket
resource "aws_s3_bucket" "jenkins_artifacts_s3" {
  bucket = var.aws_s3_bucket # Ensures the bucket name is unique

  tags = {
    Name = "Jenkins-Server"
  }
}

# Block public access settings using aws_s3_bucket_public_access_block
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket     = aws_s3_bucket.jenkins_artifacts_s3.id
  acl        = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.jenkins_artifacts_s3.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_iam_role" "my-s3-jenkins-role" {
  name = "s3-jenkins_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "s3-jenkins-policy" {
  name   = "s3-jenkins-rw-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ReadWriteAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::jenkins_artifacts_s3",
        "arn:aws:s3:::jenkins_artifacts_s3/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3-jenkins-access" {
  policy_arn = aws_iam_policy.s3-jenkins-policy.arn
  role       = aws_iam_role.my-s3-jenkins-role.name
}

resource "aws_iam_instance_profile" "s3-jenkins-profile" {
  name = "s3-jenkins-profile"
  role = aws_iam_role.my-s3-jenkins-role.name
}