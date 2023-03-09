resource "aws_instance" "green" {
  count                       = var.enable_green_env ? var.green_instance_count : 0
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.public_subnet[*].id, count.index) // count.index % length(module.vpc.public_subnets)
  vpc_security_group_ids      = [aws_security_group.sg_instance.id]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  associate_public_ip_address = true                             // FIXME to be removed
  key_name                    = aws_key_pair.public_key.key_name // FIXME to be removed
  user_data = templatefile("${path.module}/cloudinit.tftpl", {
    version = var.green_app_version
  })
  tags = {
    Name       = "green-${count.index}"
    AppVersion = var.green_app_version
  }
}

resource "aws_lb_target_group" "green" {
  name       = "green-tg"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
  slow_start = 30
  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 10
    interval = 30
  }
}
resource "aws_lb_target_group_attachment" "green" {
  count            = length(aws_instance.green)
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = aws_instance.green[count.index].id
  port             = 80
}
