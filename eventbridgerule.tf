# Create EventBridge rule to kickoff Lambda function
resource "aws_cloudwatch_event_rule" "isolateinstance" {
  name        = "IsolateInstance"
  description = "Execute Lambda function to Isolate Instance"

  event_pattern = <<EOF
{
  "source": ["aws.securityhub"],
  "detail-type": ["Security Hub Findings - Custom Action"],
  "resources": ["${aws_securityhub_action_target.IsolateInstance.arn}"]
}
EOF
}

resource "aws_cloudwatch_event_target" "IsolateInstance" {
  rule      = aws_cloudwatch_event_rule.isolateinstance.name
  target_id = "Lambda"
  arn       = aws_lambda_function.IsolateInstance.arn
}