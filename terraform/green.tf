resource "aws_launch_template" "green_launch_template" {
  name_prefix   = "green-instance-"
  image_id      = data.aws_ami.linux_image.id
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }


  user_data = base64encode(templatefile("${path.module}/cloudinit.tftpl", {
    version = var.green_app_version
    region  = var.region
    account = data.aws_caller_identity.current.account_id
  }))

  update_default_version = true

  vpc_security_group_ids = [aws_security_group.sg_instance.id]

  # Specify all options, otherwise the instance_metadata_tags argument is not
  # taken into account
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  key_name = aws_key_pair.public_key.key_name // FIXME to be removed
}

resource "aws_autoscaling_group" "green_asg" {
  name                = "green-instance-asg"
  vpc_zone_identifier = aws_subnet.private_subnet[*].id

  desired_capacity = var.enable_green_env ? var.green_instance_count : 0
  max_size         = 10
  min_size         = var.enable_green_env ? var.green_instance_count : 0

  target_group_arns = [aws_lb_target_group.green.arn]

  launch_template {
    id      = aws_launch_template.green_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "AppVersion"
    value               = var.green_app_version
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "Green"
    propagate_at_launch = true
  }

  tag {
    key                 = "Color"
    value               = "green"
    propagate_at_launch = true
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
