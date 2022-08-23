# Lambda assume role
resource "aws_iam_role" "adjust_sg_role" {
  name = "adjust_sg_role"
  path = "/"

  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
    EOF
}

# Create Policy for IAM Role (Adjust SG)
resource "aws_iam_policy" "adjust_sg_policy" {
  name        = "adjust_sg_policy"
  description = "Policy to allow adjusting security groups"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:Describe*",
                "ec2:ModifyInstanceAttribute",
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

# Attach IAM Role and the new created Policy
resource "aws_iam_role_policy_attachment" "AdjustSGPolicy" {
  role       = aws_iam_role.adjust_sg_role.name
  policy_arn = aws_iam_policy.adjust_sg_policy.arn
}

resource "aws_iam_role_policy_attachment" "CloudWatchLogs" {
  role       = aws_iam_role.adjust_sg_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create Lambda function to isolate an EC2 instance
resource "aws_lambda_function" "IsolateInstance" {
  filename      = "isolateinstance.zip"
  function_name = "IsolateInstance"
  role          = aws_iam_role.adjust_sg_role.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("isolateinstance.zip")

  runtime = "python3.7"

  environment {
    variables = {
      foo = "bar"
    }
  }
}