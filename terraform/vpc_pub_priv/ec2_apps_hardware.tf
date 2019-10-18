
resource "aws_instance" "hardware" {
  ami           = "${var.ami_id}"
  instance_type = "${var.ec2_instance_type}"
  key_name      = "${var.ec2_key}"
  vpc_security_group_ids = ["${aws_security_group.private_sg.id}"]
  subnet_id = "${aws_subnet.private_subnet_1.id}"
  # private_ip = "192.168.21.20"
  user_data = "${file("provision_hardware.sh")}"
  depends_on = ["aws_route_table_association.private_subnet_1"]
 
  tags = {
    Name = "Hardware"
  }
}
