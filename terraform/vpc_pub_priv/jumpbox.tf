

resource "aws_security_group" "public_jumbox" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${aws_vpc.infrastructure_vpc.id}"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${var.my_ip_address}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["${var.vpc_default_route}"]
  }

  tags = {
    Name = "Allow 22"
  }
}

############################################################################
resource "aws_instance" "jumpbox" {
  ami           = "${var.ami_id}"
  #ami            = "ami-00eb20669e0990cb4"
  instance_type = "${var.ec2_instance_type}"
  key_name      = "${var.ec2_key}"
  vpc_security_group_ids = ["${aws_security_group.public_jumbox.id}"]
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  user_data = "${file("provision_jumpbox.sh")}"
 
  tags = {
    Name = "Jumpbox"
  }
}
