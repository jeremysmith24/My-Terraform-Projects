terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-jsmith"
    key    = "MyTerraformKey.tfstate"
    region = "us-east-1"
  }
}