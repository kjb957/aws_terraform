
############################################################################
resource "aws_lb_target_group" "portal_target_group" {
  name     = "Portal-ALB-TG"
  port     = 5000
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.infrastructure_vpc.id}"

    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 20
    port                = 5000
    path                = "/test/"
    interval            = 120
  }
}



############################################################################
############################################################################
resource "aws_lb" "portal_lb" {
  name               = "Portal-LB"
  internal           = false
  load_balancer_type = "application"
  subnets = ["${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}"]
  security_groups = ["${aws_security_group.public_elb_sg.id}"]

  enable_deletion_protection = false

  tags = {
    Name = "portal-alb"
  }
}

############################################################################

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.portal_lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.portal_target_group.arn}"
  }
}
############################################################################
resource "aws_lb_listener_rule" "static" {
  listener_arn = "${aws_lb_listener.front_end.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.portal_target_group.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}

############################################################################
resource "aws_launch_configuration" "portal_launch_config" {
  name_prefix          = "portal_launch_config-"
  image_id      = "ami-00eb20669e0990cb4"
  instance_type = "t2.micro"
  key_name = "my_default_key_pair"
  user_data = "${file("provision_portal.sh")}"
  security_groups = ["${aws_security_group.public_sg.id}"]
  enable_monitoring = "false"
 
  lifecycle {
    create_before_destroy = true
  }
}

############################################################################

resource "aws_autoscaling_group" "portal" {
  name                 = "portal_auto_scale_group"
  launch_configuration = "${aws_launch_configuration.portal_launch_config.name}"
  desired_capacity     = 1
  # load_balancers       = ["${aws_lb.portal_lb.name}"]
  target_group_arns    = ["${aws_lb_target_group.portal_target_group.arn}"]
  max_size             = 2
  min_size             = 1
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = ["${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}"]

  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = false

}
############################################################################