provider "aws" {
  region     = "${var.aws_region}"
}

############################################################################
resource "aws_vpc" "infrastructure_vpc" {
  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "Infrastructure VPC"
  }
}