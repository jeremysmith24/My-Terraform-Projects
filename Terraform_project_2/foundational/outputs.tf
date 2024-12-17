# Output the VPC ID (Optional)
output "default_vpc_id" {
  description = "Default VPC ID"
  value       = aws_default_vpc.default-vpc.id
}

# Display the public IPs of running instances
output "public_ips" {
  description = "Public IP addresses of the Auto Scaling Group instances"
  value       = [for instance in data.aws_instances.asg_instances.public_ips : instance]
}