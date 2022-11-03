resource "aws_route53_zone" "mcs-public-hosted-zone" {
  name = var.public_hosted_zone_name
}
