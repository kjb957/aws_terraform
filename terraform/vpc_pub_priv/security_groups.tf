############################################################################

resource "aws_security_group" "public_sg" {
  name        = "Public Subnet 5000"
  description = "Allow 5000 & 22"
  vpc_id      = "${aws_vpc.infrastructure_vpc.id}"
  tags = {
    Name = "Public Subnet Allow 5000 & 22"
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${var.my_ip_address}", "${var.vpc_cidr_block}"]
  }
  ingress {
    description = "Allow Port 5000"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${var.my_ip_address}", "${var.vpc_cidr_block}"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["${var.vpc_default_route}"]
  }

}

############################################################################
resource "aws_security_group" "private_sg" {
  name        = "Private Subnet 5001"
  description = "Allow 5001 & 22 internally"
  vpc_id      = "${aws_vpc.infrastructure_vpc.id}"
  tags = {
    Name = "Private Subnet Allow 5001 & 22"
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  ingress {
    description = "Allow Port 5000"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["${var.vpc_default_route}"]
  }
}

############################################################################

############################################################################
resource "aws_security_group" "public_elb_sg" {
  name        = "Public_ELB_80"
  description = "Allow 80 from External Public"
  vpc_id      = "${aws_vpc.infrastructure_vpc.id}"

  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
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
    Name = "External Facing Port 80"
  }
}

############################################################################