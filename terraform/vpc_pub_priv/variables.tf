# file name is variables.tf

variable "ec2_key" {
  type = "string"
  description = "aws key allowing ec2 access"
  default = "my_default_key_pair"
}

variable "aws_region" {
  type = "string"
  description = "aws region"
  default = "us-east-1"
}

# Networking

variable "my_ip_address" {
  type = "string"
  description = "vpc_cidr_block for VPC"
  default = "71.245.226.55/32"
}

variable "vpc_cidr_block" {
  type = "string"
  description = "vpc_cidr_block for VPC"
  default = "192.168.0.0/16"
}

variable "vpc_subnets" {
  type = "map"
  description = "Subnets within the VPC"
  default = {
    public_subnet_1 = "192.168.11.0/24"
    public_subnet_2 = "192.168.12.0/24"
    private_subnet_1 = "192.168.21.0/24"
    private_subnet_2 = "192.168.22.0/24"
  }
}

variable "vpc_default_route" {
  type = "string"
  description = "Default Route for VPC"
  default = "0.0.0.0/0"
}

# EC2

variable "ami_id" {
  type = "string"
  description = "AMI instance id"
  default = "ami-00eb20669e0990cb4"
}

variable "ec2_instance_type" {
  type = "string"
  description = "EC2 Instance Type"
  default = "t2.micro"
}

# MySQL DB

  variable "db_admin_username" {
    type = "string"
    description = "Username of DB Admin"
    default = "admin"
  }

   variable "db_admin_password" {
    type = "string"
    description = "Username of DB Admin"
    default = "My_db_Password"
  } 

   variable "db_database" {
    type = "string"
    description = "Name of DataBase"
    default = "hardwareavailability"
  } 

