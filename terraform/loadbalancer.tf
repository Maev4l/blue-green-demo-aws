
locals {
  traffic_distribution = {
    blue = {
      blue  = 100
      green = 0
    }
    blue-75 = {
      blue  = 75
      green = 10
    }
    even = {
      blue  = 50
      green = 50
    }
    green-75 = {
      blue  = 10
      green = 75
    }
    green = {
      blue  = 0
      green = 100
    }
  }
}

resource "aws_security_group" "sg_lb" {
  name        = "demo-blue-green-lb-sg"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = aws_vpc.main.id
}

// Allow all incoming HTTP requests
resource "aws_vpc_security_group_ingress_rule" "ingress_rules_lb" {
  security_group_id = aws_security_group.sg_lb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

// Allow only outgoing requests to the private instances
resource "aws_vpc_security_group_egress_rule" "egress_rules_lb" {
  security_group_id            = aws_security_group.sg_lb.id
  referenced_security_group_id = aws_security_group.sg_instance.id
  ip_protocol                  = "-1"
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
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = lookup(local.traffic_distribution[var.traffic_distribution], "blue", 100)
      }
      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = lookup(local.traffic_distribution[var.traffic_distribution], "green", 0)
      }

      stickiness {
        duration = 1
      }
    }
  }
}
