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