



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



resource "aws_elb" "portal" {
  name               = "portal-elb"
  subnets = ["${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}"]
  security_groups = ["${aws_security_group.public_elb_sg.id}"]


  listener {
    instance_port     = 5000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 20
    target              = "HTTP:5000/test/"
    interval            = 120
  }

  #instances                   = ["${aws_instance.foo.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "portal-elb"
  }
}

############################################################################
resource "aws_autoscaling_group" "portal" {
  name                 = "portal_auto_scale_group"
  launch_configuration = "${aws_launch_configuration.portal_launch_config.name}"
  desired_capacity     = 1
  load_balancers       = ["${aws_elb.portal.name}"]
  max_size             = 2
  min_size             = 1
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = ["${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}"]

  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = false

}
############################################################################





############################################################################

