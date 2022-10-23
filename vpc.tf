resource "aws_vpc" "mcs-vpc" {
  cidr_block          = "172.16.0.0/20"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "htr-mcs-vpc"
  }
}
