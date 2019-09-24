

resource "aws_security_group" "public_jumbox" {
  name        = "allow_web_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${aws_vpc.infrastructure_vpc.id}"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["71.245.226.55/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow 22"
  }
}

############################################################################
resource "aws_instance" "jumpbox" {
  #ami           = "ami-0c46f9f09e3a8c2b5"
  ami            = "ami-00eb20669e0990cb4"
  instance_type = "t2.micro"
  key_name = "my_default_key_pair"
  vpc_security_group_ids = ["${aws_security_group.public_jumbox.id}"]
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  #user_data = "${file("provision_jumbox.sh")}"
 
  tags = {
    Name = "Jumpbox"
  }
}