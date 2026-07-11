locals {
  functions = {
    process_sqs_event = {
      environments = {
        ENVIRONMENT = "production"
        LOG_LEVEL   = "info"
      }
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
  name               = "${var.project_name}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


# Create an IAM policy for the Lambda function to allow it to consume messages from SQS queues
data "aws_iam_policy_document" "worker_permissions" {
  statement {
    sid    = "ConsumeQueues"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [for q in aws_sqs_queue.main : q.arn]
  }

  statement {
    sid    = "TableDataPlaneOnly"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem"
    ]
    resources = [
      aws_dynamodb_table.lab.arn,
      "${aws_dynamodb_table.lab.arn}/index/*"
    ]
  }
}

resource "aws_iam_role_policy" "worker_permissions" {
  name   = "${var.project_name}-worker-permissions"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.worker_permissions.json
}

# Attach the AWSLambdaBasicExecutionRole policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "lambda" {
  for_each = local.functions

  filename         = "${path.module}/functions/zips/${each.key}.zip"
  function_name    = "${var.project_name}-${each.key}"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.handler"
  timeout          = 30
  source_code_hash = filebase64sha256("${path.module}/functions/zips/${each.key}.zip")

  runtime = "nodejs24.x"

  environment {
    variables = each.value.environments
  }
}
