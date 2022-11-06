locals {
  vpc = data.terraform_remote_state.vpc.outputs.vpc_id
  PrivateSubnet1 = data.terraform_remote_state.vpc.outputs.PvtSN1_id
  PrivateSubnet2 = data.terraform_remote_state.vpc.outputs.PvtSN2_id
  PrivateSubnet3 = data.terraform_remote_state.vpc.outputs.PvtSN3_id
  PublicSubnet1 = data.terraform_remote_state.vpc.outputs.PubSN1_id
  PublicSubnet2 = data.terraform_remote_state.vpc.outputs.PubSN2_id
  PublicSubnet3 = data.terraform_remote_state.vpc.outputs.PubSN3_id
  web-alb-sg = data.terraform_remote_state.vpc.outputs.web_alb_sg
  alb_s3_bucket = data.terraform_remote_state.s3.outputs.alb_s3_bucket
  bastion_template = data.terraform_remote_state.ec2.outputs.bastion_template
  web_template = data.terraform_remote_state.ec2.outputs.web_template
  web_template_version = data.terraform_remote_state.ec2.outputs.web_template_version
}

resource "aws_lb_target_group" "web" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc
}

resource "aws_lb" "web-server-lb" {
  name               = "web-server-lb"
  internal           = false
  enable_cross_zone_load_balancing = true
  load_balancer_type = "application"
  security_groups    = [local.web-alb-sg]
  subnets            = [local.PublicSubnet1, local.PublicSubnet2, local.PublicSubnet3]
  

  enable_deletion_protection = false

  access_logs {
    bucket  = local.alb_s3_bucket
    prefix  = "Logs"
    enabled = true
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web-server-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_autoscaling_group" "bastion-host-asg" {
  name                      = "bastion-host-asg"
  max_size                  = 6
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  vpc_zone_identifier       = [local.PublicSubnet1, local.PublicSubnet2, local.PublicSubnet3]
  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "bastion"
        "propagate_at_launch" = true
      }
    ]
  )

  launch_template {
    id      = local.bastion_template
    version = local.web_template_version
  }
}

resource "aws_autoscaling_group" "web-host-asg" {
  name                      = "web-host-asg"
  max_size                  = 6
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns   = [aws_lb_target_group.web.arn]
  desired_capacity    = 3
  force_delete        = true
  vpc_zone_identifier = [local.PrivateSubnet1, local.PrivateSubnet2, local.PrivateSubnet3]
  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "web-server"
        "propagate_at_launch" = true
      }
    ]
  )

  launch_template {
    id = local.web_template
    version = local.web_template_version
  }
}