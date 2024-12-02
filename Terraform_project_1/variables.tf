variable "region" {
  type    = string
  default = "us-east-1" # You can change this if needed
}

variable "instance_type" {
  description = "Amazon Linux"
  default     = "t2.micro" # Adjust as necessary
}

variable "ami" {
  default = "ami-0453ec754f44f9a4a"
  type    = string
}

variable "key_name" {
  default = "jenkinskp"
  type    = string
}

