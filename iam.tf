data "aws_iam_policy_document" "mcs-ec2-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "amazon-ssm-managed-instance-core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "mcs-ec2-role" {
  name                = "${var.resource_name_prefix}-mcs-ec2-role"
  assume_role_policy  = data.aws_iam_policy_document.mcs-ec2-assume-role-policy.json
  managed_policy_arns = [data.aws_iam_policy.amazon-ssm-managed-instance-core.arn]

  tags = {
    Name = "${var.resource_name_prefix}-mcs-ec2-role"
  }
}

resource "aws_iam_instance_profile" "mcs-ec2-instance-profile" {
  name = "${var.resource_name_prefix}-mcs-ec2-role"
  role = aws_iam_role.mcs-ec2-role.name
}

data "aws_iam_policy_document" "mcs-function-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mcs-lambda-basic-execution-policy-document" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "mcs-lambda-basic-execution-policy" {
  name        = "${var.resource_name_prefix}-mcs-lambda-basic-execution-policy"
  description = "${var.resource_name_prefix}-mcs-lambda-basic-execution-policy"
  policy      = data.aws_iam_policy_document.mcs-lambda-basic-execution-policy-document.json
}

data "aws_iam_policy_document" "mcs-ec2-control-policy-document" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "mcs-ec2-control-policy" {
  name        = "${var.resource_name_prefix}-mcs-ec2-control-policy"
  description = "${var.resource_name_prefix}-mcs-ec2-control-policy"
  policy      = data.aws_iam_policy_document.mcs-ec2-control-policy-document.json
}

resource "aws_iam_role" "mcs-function-role" {
  name               = "${var.resource_name_prefix}-mcs-function-role"
  assume_role_policy = data.aws_iam_policy_document.mcs-function-assume-role-policy.json
  managed_policy_arns = [
    aws_iam_policy.mcs-lambda-basic-execution-policy.arn,
    aws_iam_policy.mcs-ec2-control-policy.arn
  ]

  tags = {
    Name = "${var.resource_name_prefix}-mcs-function-role"
  }
}
