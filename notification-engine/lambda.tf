locals {
  functions = {
    name = "process_sqs_event"
    environments = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
    }
  }
}

# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create the IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


# Attach the AWSLambdaBasicExecutionRole policy to the IAM role
resource "aws_lambda_function" "lambda" {
  for_each = local.functions

  filename         = "${path.module}/functions/zips/${each.value.name}.zip"
  function_name    = each.value.name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.handler"
  timeout          = 30
  source_code_hash = filebase64sha256("${path.module}/functions/zips/${replace(each.key, "${var.project_name_env}-", "")}.zip")

  runtime = "nodejs24.x"

  environment {
    variables = each.value.environments
  }
}
