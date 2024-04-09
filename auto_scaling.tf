

resource "aws_launch_template" "meu-template" {
  name = "meu-template"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  network_interfaces {

    security_groups = [aws_security_group.grupo_seguranca.id]
  }

  image_id      = var.ec2_ami_id
  instance_type = var.tipo-instancia
  key_name      = var.key-name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "exemplo-instance"
    }
  }
}

resource "aws_autoscaling_group" "autoscaling-gp" {
  name                      = "Autoscaling Group"
  vpc_zone_identifier       = [aws_subnet.subnet_privada_a.id, aws_subnet.subnet_privada_b.id]
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 240
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.target_group.id]

  launch_template {
    id      = aws_launch_template.meu-template.id
    version = aws_launch_template.meu-template.latest_version
  }
}

resource "aws_autoscaling_policy" "scaleup" {
  name                   = "Scale Up"
  autoscaling_group_name = aws_autoscaling_group.autoscaling-gp.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "180"
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scaledown" {
  name                   = "Scale Down"
  autoscaling_group_name = aws_autoscaling_group.autoscaling-gp.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "180"
  policy_type            = "SimpleScaling"
}