resource "aws_vpc" "mcs-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.resource_name_prefix}-mcs-vpc"
  }
}

resource "aws_subnet" "mcs-subnet-a" {
  vpc_id                  = aws_vpc.mcs-vpc.id
  cidr_block              = var.public_subnet_a_cidr_block
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.resource_name_prefix}-mcs-public-subnet-a"
  }
}

resource "aws_subnet" "mcs-subnet-c" {
  vpc_id                  = aws_vpc.mcs-vpc.id
  cidr_block              = var.public_subnet_c_cidr_block
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.resource_name_prefix}-mcs-public-subnet-c"
  }
}

resource "aws_internet_gateway" "mcs-igw" {
  vpc_id = aws_vpc.mcs-vpc.id

  tags = {
    Name = "${var.resource_name_prefix}-mcs-igw"
  }
}
