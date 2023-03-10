output "lb_public_dns" {
  value = aws_lb.lb.dns_name
}

/*
output "blue_instances" {
  value = aws_instance.blue[*].id
}

output "green_instances" {
  value = aws_instance.green[*].id
}
*/
