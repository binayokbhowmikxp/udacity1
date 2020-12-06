provider "aws" {
  region = var.region
}


data "archive_file" "lambda_inline_zip" {
  output_path = "/tmp/greet_lambda.zip"
  type = "zip"
  source_file = "greet_lambda.py"
}

resource "aws_lambda_function" "udacity_lambda" {
  function_name = var.lambda_name
  filename = data.archive_file.lambda_inline_zip.output_path
  handler = "greet_lambda.lambda_handler"
  role = aws_iam_role.iam_for_lambda.arn
  runtime = "python3.6"
  source_code_hash = data.archive_file.lambda_inline_zip.output_base64sha256

  vpc_config {
    security_group_ids = ["sg-ae99a181"]
    subnet_ids = ["subnet-c08e0b8d"]
  }

  environment {
      variables = {
        greeting = "Udacity" 
      }
  }

}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 14
}

resource "aws_iam_role" "iam_for_lambda" {
name = "iam_for_lambda"

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

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
