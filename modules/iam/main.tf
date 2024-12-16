resource "aws_iam_policy" "terraform_s3_policy" {
  name        = "terraform-s3-policy"
  description = "Policy to allow access to Terraform state in S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource  = [
          "arn:aws:s3:::my-tfstate-bucket-24",   # Bucket name
          "arn:aws:s3:::my-tfstate-bucket-24/*"   # Objects in the bucket
        ]
      }
    ]
  })
}

# Create IAM Role
resource "aws_iam_role" "terraform_role" {
  name               = "terraform-s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"  # For EC2 instance, adjust if using other services
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.terraform_s3_policy.arn
}

# Assign IAM Role to EC2 Instance or Terraform Execution Environment
resource "aws_instance" "terraform_instance" {
  ami           = var.ami_id  # Replace with your desired AMI
  instance_type = var.instance_type
  key_name      = "my-terraform-key-2" # Replace with your EC2 key name

  iam_instance_profile = aws_iam_role.terraform_role.name  # Attach IAM role to EC2 instance

  # Other instance configurations as needed
}

# Define IAM Role
resource "aws_iam_role" "terraform_s3_role" {
  name               = "terraform-s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

# Define IAM Instance Profile
resource "aws_iam_instance_profile" "terraform_instance_profile" {
  name = "terraform-s3-instance-profile"
  role = aws_iam_role.terraform_s3_role.name
}

# Output the instance profile name for reference in other modules
output "terraform_instance_profile" {
  value = aws_iam_instance_profile.terraform_instance_profile.name
}