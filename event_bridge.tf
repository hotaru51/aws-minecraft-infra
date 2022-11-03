resource "aws_cloudwatch_event_rule" "mcs-instance-state-event" {
  name          = "${var.resource_name_prefix}-mcs-instance-state-event"
  description   = "${var.resource_name_prefix}-mcs-instance-state-event"
  event_pattern = <<EOF
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["stopping", "running"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "mcs-instance-state-event-target" {
  rule = aws_cloudwatch_event_rule.mcs-instance-state-event.name
  arn  = aws_lambda_function.mcs-register-dns-record-function.arn
}
