

resource "aws_security_group" "rds_mysql_security_group" {
  name        = "Access_to_MySql"
  description = "Allow inbound to port 3306"
  vpc_id      = "${aws_vpc.infrastructure_vpc.id}"

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
    description = "Allow Port 3306"
    from_port   = 3306
    to_port     = 3306
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

  tags = {
    Name = "Allow 3306 & 22"
  }
}  

resource "aws_db_subnet_group" "rds_mysql" {
  name       = "mysql_db_subnet_group"
  description = "Database Subnet Group"
  subnet_ids = ["${aws_subnet.private_subnet_1.id}", "${aws_subnet.private_subnet_2.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "hardwareavailability"
  username             = "admin"
  password             = "My_db_Password"
  parameter_group_name = "default.mysql5.7"
  deletion_protection  = "false"
  db_subnet_group_name = "${aws_db_subnet_group.rds_mysql.id}"
  vpc_security_group_ids = ["${aws_security_group.rds_mysql_security_group.id}"]
  port = "3306"
  multi_az = "false"
  publicly_accessible = "false"
  backup_retention_period = "5"
}

