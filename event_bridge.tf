resource "aws_cloudwatch_event_rule" "mcs-server-stop-event" {
  name          = "${var.resource_name_prefix}-mcs-server-stop-event"
  description   = "${var.resource_name_prefix}-mcs-server-stop-event"
  event_pattern = <<EOF
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["stopping"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "mcs-server-stop-event-target" {
  rule = aws_cloudwatch_event_rule.mcs-server-stop-event.name
  arn  = aws_lambda_function.mcs-delete-dns-record-function.arn
}
