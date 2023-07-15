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
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cloudwatch-agent-server-policy" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "mcs-s3-access-policy-document" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject*",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.mcs-data-bucket.arn,
      "${aws_s3_bucket.mcs-data-bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "mcs-s3-access-policy" {
  name        = "${var.resource_name_prefix}-mcs-s3-access-policy"
  description = "${var.resource_name_prefix}-mcs-s3-access-policy"
  policy      = data.aws_iam_policy_document.mcs-s3-access-policy-document.json
}

resource "aws_iam_role" "mcs-ec2-role" {
  name               = "${var.resource_name_prefix}-mcs-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.mcs-ec2-assume-role-policy.json
  managed_policy_arns = [
    data.aws_iam_policy.amazon-ssm-managed-instance-core.arn,
    data.aws_iam_policy.cloudwatch-agent-server-policy.arn,
    aws_iam_policy.mcs-s3-access-policy.arn
  ]

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

data "aws_iam_policy_document" "mcs-hosted-zone-policy-document" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]

    resources = [
      aws_route53_zone.mcs-public-hosted-zone.arn
    ]
  }
}

resource "aws_iam_policy" "mcs-hosted-zone-policy" {
  name        = "${var.resource_name_prefix}-mcs-hosted-zone-policy"
  description = "${var.resource_name_prefix}-mcs-hosted-zone-policy"
  policy      = data.aws_iam_policy_document.mcs-hosted-zone-policy-document.json
}

data "aws_iam_policy_document" "mcs-ssm-parameter-policy-document" {
  statement {
    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      data.aws_ssm_parameter.mcs-token-parameter.arn
    ]
  }
}

resource "aws_iam_policy" "mcs-ssm-parameter-policy" {
  name        = "${var.resource_name_prefix}-mcs-ssm-parameter-policy"
  description = "${var.resource_name_prefix}-mcs-ssm-parameter-policy"
  policy      = data.aws_iam_policy_document.mcs-ssm-parameter-policy-document.json
}

resource "aws_iam_role" "mcs-function-role" {
  name               = "${var.resource_name_prefix}-mcs-function-role"
  assume_role_policy = data.aws_iam_policy_document.mcs-function-assume-role-policy.json
  managed_policy_arns = [
    aws_iam_policy.mcs-lambda-basic-execution-policy.arn,
    aws_iam_policy.mcs-ec2-control-policy.arn,
    aws_iam_policy.mcs-hosted-zone-policy.arn,
    aws_iam_policy.mcs-ssm-parameter-policy.arn
  ]

  tags = {
    Name = "${var.resource_name_prefix}-mcs-function-role"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "mcs-automation-assume-role-policy-document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:automation-execution/*"
      ]
    }
  }
}

data "aws_iam_policy" "amazon-ssm-automation-role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_iam_role" "mcs-ssm-automation-role" {
  name                = "${var.resource_name_prefix}-mcs-ssm-automation-role"
  assume_role_policy  = data.aws_iam_policy_document.mcs-automation-assume-role-policy-document.json
  managed_policy_arns = [data.aws_iam_policy.amazon-ssm-automation-role.arn]

  tags = {
    Name = "${var.resource_name_prefix}-mcs-ssm-automation-role"
  }
}

data "aws_iam_policy_document" "mcs-mw-assume-role-policy-document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "amazon-ssm-maintenance-window-role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

data "aws_iam_policy_document" "mcs-pass-role-policy-document" {
  statement {
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.mcs-ssm-automation-role.arn]
  }
}

resource "aws_iam_role" "mcs-ssm-maintenance-window-role" {
  name                = "${var.resource_name_prefix}-mcs-ssm-maintenance-window-role"
  assume_role_policy  = data.aws_iam_policy_document.mcs-mw-assume-role-policy-document.json
  managed_policy_arns = [data.aws_iam_policy.amazon-ssm-maintenance-window-role.arn]
  inline_policy {
    name   = "automation-passrole"
    policy = data.aws_iam_policy_document.mcs-pass-role-policy-document.json
  }

  tags = {
    Name : "${var.resource_name_prefix}-mcs-ssm-maintenance-window-role"
  }
}
