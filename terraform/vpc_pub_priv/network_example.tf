provider "aws" {
  region     = "us-east-1"
}

resource "aws_key_pair" "my_default_key_pair" {
  key_name   = "my_default_key_pair"
  public_key = "${file("my_default.pub")}"
}



resource "aws_vpc" "infrastructure_vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "Infrastructure VPC"
  }
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = "${aws_vpc.infrastructure_vpc.id}"
  cidr_block = "192.168.11.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "Public Subnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = "${aws_vpc.infrastructure_vpc.id}"
  cidr_block = "192.168.12.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "Public Subnet2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = "${aws_vpc.infrastructure_vpc.id}"
  cidr_block = "192.168.21.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "Private Subnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = "${aws_vpc.infrastructure_vpc.id}"
  cidr_block = "192.168.22.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "Private Subnet2"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.infrastructure_vpc.id}"

  tags = {
    Name = "Infrastructure IG"
  }
}

resource "aws_route_table" "default_public_route" {
  vpc_id = "${aws_vpc.infrastructure_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags = {
    Name = "Default Public Route"
  }
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.default_public_route.id}"
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.default_public_route.id}"
}

resource "aws_eip" "nat_gw_1" {
  vpc      = true
  depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_eip" "nat_gw_2" {
  vpc      = true
  depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = "${aws_eip.nat_gw_1.id}"
  subnet_id     = "${aws_subnet.public_subnet_1.id}"

  tags = {
    Name = "NAT GW 1"
  }
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = "${aws_eip.nat_gw_2.id}"
  subnet_id     = "${aws_subnet.public_subnet_2.id}"

  tags = {
    Name = "NAT GW 2"
  }
}

resource "aws_route_table" "default_private_route_1" {
  vpc_id = "${aws_vpc.infrastructure_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat_gw_1.id}"
  }

  tags = {
    Name = "Default Private Route 1"
  }
}

resource "aws_route_table" "default_private_route_2" {
  vpc_id = "${aws_vpc.infrastructure_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat_gw_2.id}"
  }

  tags = {
    Name = "Default Private Route 2"
  }
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = "${aws_subnet.private_subnet_1.id}"
  route_table_id = "${aws_route_table.default_private_route_1.id}"
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = "${aws_subnet.private_subnet_2.id}"
  route_table_id = "${aws_route_table.default_private_route_2.id}"
}

resource "aws_security_group" "public_sg" {
  name        = "allow_tls"
  description = "Allow inbound traffic"
  vpc_id      = "${aws_vpc.infrastructure_vpc.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "-1"
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
    Name = "allow 5001"
  }
}


resource "aws_instance" "portal" {
  ami           = "ami-0c46f9f09e3a8c2b5"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.my_default_key_pair.key_name}"
  vpc_security_group_ids = ["${aws_security_group.public_sg.id}"]
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  user_data = "${file("provision_portal.sh")}"
 
  tags = {
    Name = "Portal"
  }
}

