resource "aws_security_group" "mcs-instance-sg" {
  name        = "${var.resource_name_prefix}-mcs-instance-sg"
  description = "${var.resource_name_prefix}-mcs-instance-sg"
  vpc_id      = aws_vpc.mcs-vpc.id

  ingress {
    description = "allow minecraft server listen port"
    from_port   = var.mcs_listen_port
    to_port     = var.mcs_listen_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.resource_name_prefix}-mcs-instance-sg"
  }
}
