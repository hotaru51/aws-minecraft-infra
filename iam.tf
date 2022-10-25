data "aws_iam_policy_document" "mcs-ec2-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "amazon-ssm-management-instance-core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "mcs-ec2-role" {
  name                = "${var.resource_name_prefix}-mcs-ec2-role"
  assume_role_policy  = data.aws_iam_policy_document.mcs-ec2-assume-role-policy.json
  managed_policy_arns = [data.aws_iam_policy.amazon-ssm-management-instance-core.arn]

  tags = {
    Name = "${var.resource_name_prefix}-mcs-ec2-role"
  }
}

resource "aws_iam_instance_profile" "mcs-ec2-instance-profile" {
  name = "${var.resource_name_prefix}-mcs-ec2-role"
  role = aws_iam_role.mcs-ec2-role.name
}
