output "service_ami_id" {
  value = data.aws_ami.fake_service.id
}

output "statement_private_ip" {
  value = aws_instance.statement.private_ip
}

output "account_private_ip" {
  value = aws_instance.account.private_ip
}

output "customer_profile_url" {
  value = "http://${aws_instance.customer_profile.public_ip}:${var.service_port}/"
}
