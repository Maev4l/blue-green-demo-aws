resource "aws_instance" "bastion" {
  ami           = data.aws_ami.linux_image.id
  instance_type = "t2.nano"

  associate_public_ip_address = true

  key_name = aws_key_pair.public_key.key_name

  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg_bastion.id]
  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "sg_bastion" {
  name        = "demo-blue-green-bastion-sg"
  description = "Security group bastion"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules_ssh_bastion" {
  security_group_id = aws_security_group.sg_bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "egress_rules_bastion" {
  security_group_id = aws_security_group.sg_bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

