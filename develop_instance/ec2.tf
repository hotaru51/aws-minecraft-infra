data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "owner-id"
    values = ["099720109477"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "mcs-dev-instance" {
  ami                         = var.dev_ami_id == null ? data.aws_ami.ubuntu.id : var.dev_ami_id
  associate_public_ip_address = true
  iam_instance_profile        = data.terraform_remote_state.mcs.outputs.mcs-iam-name
  instance_type               = "t3a.micro"
  key_name                    = var.mcs_keypair
  vpc_security_group_ids      = [data.terraform_remote_state.mcs.outputs.mcs-sg-id]
  subnet_id                   = data.terraform_remote_state.mcs.outputs.mcs-subnet-a-id

  root_block_device {
    volume_size = var.dev_ami_id == null ? 8 : 16 # TODO:初回は16GBで作ってしまったので念のため分岐
    volume_type = "gp3"

    tags = {
      Name = "${var.resource_name_prefix}-mcs-sv-00a"
    }
  }

  tags = {
    Name          = "${var.resource_name_prefix}-mcs-sv-00a"
    Record        = "d1"
    InstanceGroup = "${var.resource_name_prefix}"
  }
}
