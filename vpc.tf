resource "aws_vpc" "mcs-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.resource_name_prefix}-mcs-vpc"
  }
}
