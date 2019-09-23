############################################################################
resource "aws_eip" "nat_gw_1" {
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

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = "${aws_subnet.private_subnet_1.id}"
  route_table_id = "${aws_route_table.default_private_route_1.id}"
}

############################################################################