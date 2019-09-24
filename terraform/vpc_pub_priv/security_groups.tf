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
    cidr_blocks = ["71.245.226.55/32", "192.168.0.0/16"]
  }
  ingress {
    description = "Allow Port 5000"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["71.245.226.55/32", "192.168.0.0/16"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
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
    cidr_blocks = ["192.168.0.0/16"]
  }
  ingress {
    description = "Allow Port 5000"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["192.168.0.0/16"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
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
    cidr_blocks = ["71.245.226.55/32"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "External Facing Port 80"
  }
}

############################################################################