# Output the EC2 instance public IP
output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.builder.public_ip
}

# Output the EC2 instance public DNS
output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.builder.public_dns
}

# Output the SSH private key path
output "ssh_private_key_path" {
  description = "Path to the generated private SSH key"
  value       = local_file.private_key.filename
  sensitive   = true
}

# Output the SSH key name
output "ssh_key_name" {
  description = "Name of the AWS SSH key pair"
  value       = aws_key_pair.builder_key.key_name
}

# Output the security group ID
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.builder_sg.id
}

# Output the instance ID
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.builder.id
}

# Output SSH connection command
output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.builder.public_ip}"
}

# Output current IP used for security group
output "current_ip" {
  description = "Current public IP used for security group access"
  value       = "${chomp(data.http.current_ip.response_body)}/32"
}
