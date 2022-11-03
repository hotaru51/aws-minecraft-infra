resource "aws_instance" "mcs-instance" {
  ami                         = var.mcs_ami_id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.mcs-ec2-instance-profile.name
  instance_type               = var.mcs_instance_type
  key_name                    = var.mcs_keypair
  security_groups             = [aws_security_group.mcs-instance-sg.id]
  subnet_id                   = aws_subnet.mcs-subnet-a.id

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
  }

  tags = {
    Name   = "${var.resource_name_prefix}-mcs-sv-01a"
    Record = var.dns_record_prefix
  }
}
