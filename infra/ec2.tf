data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20230214-x86_64-ebs"]
  }
}

resource "aws_security_group" "sg_instance" {
  name        = "demo-blue-green-instance-sg"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = aws_vpc.main.id
}

// FIXME For debug
resource "aws_vpc_security_group_ingress_rule" "ingress_rules_ssh_instance" {
  security_group_id = aws_security_group.sg_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

data "local_file" "public_key" {
  filename = pathexpand("~/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "public_key" {
  key_name   = "instance_public_key"
  public_key = data.local_file.public_key.content
}

// FIXME to ingress from load balancer
resource "aws_vpc_security_group_ingress_rule" "ingress_rules_instance" {
  security_group_id = aws_security_group.sg_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_rules_app" {
  security_group_id = aws_security_group.sg_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_iam_policy" "instance_policy" {
  name        = "blue-green-demo-instance-policy"
  path        = "/"
  description = "Role for blue green EC2 instance"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect : "Allow",
      Action : [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage"
      ]
      Resource : "*"
    }]
  })
}

resource "aws_iam_role" "instance_role" {
  name = "blue-green-demo-instance-policy"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "instance_policy_role" {
  name       = "blue-green-demo-instance-policy-role"
  roles      = [aws_iam_role.instance_role.name]
  policy_arn = aws_iam_policy.instance_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "blue-green-demo-instance-profile"
  role = aws_iam_role.instance_role.name
}
