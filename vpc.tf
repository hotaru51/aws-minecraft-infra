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

resource "aws_vpc_endpoint" "mcs-s3-endpoint" {
  vpc_id            = aws_vpc.mcs-vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${var.resource_name_prefix}-mcs-s3-endpoint"
  }
}

data "aws_ec2_managed_prefix_list" "s3-prefix-list" {
  name = "com.amazonaws.${var.region}.s3"
}

resource "aws_route_table" "mcs-public-rtb" {
  vpc_id = aws_vpc.mcs-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mcs-igw.id
  }

  tags = {
    Name = "${var.resource_name_prefix}-mcs-public-rtb"
  }
}

resource "aws_vpc_endpoint_route_table_association" "mcs-s3-endpoint-route" {
  vpc_endpoint_id = aws_vpc_endpoint.mcs-s3-endpoint.id
  route_table_id  = aws_route_table.mcs-public-rtb.id
}

resource "aws_route_table_association" "mcs-public-a-assoc" {
  subnet_id      = aws_subnet.mcs-subnet-a.id
  route_table_id = aws_route_table.mcs-public-rtb.id
}

resource "aws_route_table_association" "mcs-public-c-assoc" {
  subnet_id      = aws_subnet.mcs-subnet-c.id
  route_table_id = aws_route_table.mcs-public-rtb.id
}
