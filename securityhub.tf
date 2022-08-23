# Enable Security Hub
resource "aws_securityhub_account" "MySecurityHub" {}

# Create Security Hub Action
resource "aws_securityhub_action_target" "IsolateInstance" {
  depends_on  = [aws_securityhub_account.MySecurityHub]
  name        = "Isolate Instance"
  identifier  = "IsolateInstance"
  description = "Action that will isolate an EC2 instance with a new security group"
}