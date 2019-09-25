

############################################################################
resource "aws_instance" "portal" {
  #ami           = "ami-0c46f9f09e3a8c2b5"
  ami            = "ami-00eb20669e0990cb4"
  instance_type = "t2.micro"
  key_name = "my_default_key_pair"
  vpc_security_group_ids = ["${aws_security_group.public_sg.id}"]
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  user_data = "${file("provision_portal.sh")}"
 
  tags = {
    Name = "Portal"
  }
}

resource "aws_instance" "hardware" {
  ami            = "ami-00eb20669e0990cb4"
  instance_type = "t2.micro"
  key_name = "my_default_key_pair"
  vpc_security_group_ids = ["${aws_security_group.private_sg.id}"]
  subnet_id = "${aws_subnet.private_subnet_1.id}"
  private_ip = "192.168.21.20"
  user_data = "${file("provision_hardware.sh")}"
  depends_on = ["aws_route_table_association.private_subnet_1"]
 
  tags = {
    Name = "Hardware"
  }
}
