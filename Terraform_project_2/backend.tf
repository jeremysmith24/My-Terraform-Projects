# Backend configuration for Terraform state file in S3
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-007"                                             # Replace with your bucket name
    key            = "Users/jeremysmith/My-Terraform-Projects/Terraform_project_2/.terraform/terraform.tfstate" # Path to store the state file
    region         = "us-east-1"                                                                # Region where your bucket is located
    encrypt        = true                                                                       # Enable encryption
    dynamodb_table = "my-lock-table"                                                            # Optional: For state locking, use a DynamoDB table
  }
}