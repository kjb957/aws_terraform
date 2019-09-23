provider "aws" {
  region     = "us-east-1"
}

#resource "aws_key_pair" "private_server_key_pair" {
#  key_name   = "private_server_key_pair"
#  public_key = "${file("my_default.pub")}"
#}

############################################################################
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

############################################################################
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


############################################################################


