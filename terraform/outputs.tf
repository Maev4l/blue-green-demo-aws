output "lb_public_dns" {
  value = aws_lb.lb.dns_name
}

output "bastion_dns" {
  value = one(aws_instance.bastion[*].public_dns)
}

