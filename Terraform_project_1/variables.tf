variable "region" {
  default = "us-east-1"
  type    = string # You can change this if needed
}

variable "instance_type" {
  default = "t3.micro"
  type    = string # Adjust as necessary
}

variable "ami" {
  default = "ami-0453ec754f44f9a4a"
  type    = string
}

variable "key_name" {
  default = "jenkinskp"
  type    = string
}

variable "aws_s3_bucket" {
  default = "jenkins-artifacts-bucket007"
  type    = string
}
variable "acl" {
  default = "private"
  type    = string
}