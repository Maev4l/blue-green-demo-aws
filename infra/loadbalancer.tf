
resource "aws_security_group" "sg_lb" {
  name        = "demo-blue-green-lb-sg"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules_lb" {
  security_group_id = aws_security_group.sg_lb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

// FIXME to egress to the private instance
resource "aws_vpc_security_group_egress_rule" "egress_rules_lb" {
  security_group_id = aws_security_group.sg_lb.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "-1"

}

resource "aws_lb" "lb" {
  name               = "demo-blue-green-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnet[*].id
  security_groups    = [aws_security_group.sg_lb.id]
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}
