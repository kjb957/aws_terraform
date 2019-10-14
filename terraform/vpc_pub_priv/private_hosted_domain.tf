resource "aws_route53_zone" "private" {
  name = "myprivatedomain.com"

  vpc {
    vpc_id = "${aws_vpc.infrastructure_vpc.id}"
  }
}


resource "aws_route53_record" "mysqldb" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "mysqldb.myprivatedomain.com."
  type    = "CNAME"
  ttl     = "300"

  records        = ["${aws_db_instance.mysql_db.address}"]
}