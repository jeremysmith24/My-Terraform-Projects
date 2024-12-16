# Output the DNS name of the Application Load Balancer (ALB)
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

# Output the ARN of the Target Group for ALB
output "target_group_arn" {
  description = "The ARN of the web target group"
  value       = aws_lb_target_group.web_target_group.arn
}

# Output the name of the Auto Scaling Group (ASG)
output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}

# Output the instance IDs of the instances in the ASG
# Data block to get the instances associated with the Auto Scaling Group
data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.asg.name] # Reference the ASG's name
  }

  # Optional: Specify the region and other filtering options if necessary
}

# Output the instance IDs of the instances in the Auto Scaling Group (ASG)
output "asg_instance_ids" {
  description = "The instance IDs of the instances in the Auto Scaling Group"
  value       = data.aws_instances.asg_instances.ids # Get all instance IDs
}

# Output the name of the VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom_vpc.id
}

# Output the public subnet IDs
output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

# Output the private subnet IDs
output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

# Output the URL for the static website
output "static_website_url" {
  description = "The URL for the static website"
  value       = "http://${aws_s3_bucket.static_website.bucket}.s3-website-${var.region}.amazonaws.com/"
}