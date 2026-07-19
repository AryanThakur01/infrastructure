resource "aws_iam_role" "api_execution_role" {
  name               = "${var.project_name}-api-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_basic" {
  role       = aws_iam_role.api_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# The API enqueues notifications (SendMessage) and reads queue depth for /stats
# (GetQueueAttributes on main + DLQ, GetQueueUrl to resolve the DLQ from its
# redrive ARN). The role otherwise only has AWSLambdaBasicExecutionRole, so
# without this every request throws AccessDenied — surfaced as a 400.
data "aws_iam_policy_document" "api_permissions" {
  statement {
    sid    = "ProduceAndInspectQueues"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]
    resources = concat(
      [for q in aws_sqs_queue.main : q.arn],
      [for q in aws_sqs_queue.dlq : q.arn],
    )
  }
}

resource "aws_iam_role_policy" "api_permissions" {
  name   = "${var.project_name}-api-permissions"
  role   = aws_iam_role.api_execution_role.id
  policy = data.aws_iam_policy_document.api_permissions.json
}

resource "aws_lambda_function" "api" {
  filename      = "${path.module}/functions/zips/api.zip"
  function_name = "${var.project_name}-api"
  role          = aws_iam_role.api_execution_role.arn
  handler       = "dist/lambda.handler" # dist/lambda.js -> exported `handler`
  runtime       = "nodejs24.x"
  architectures = ["arm64"]
  timeout       = 30
  memory_size   = 512

  # Terraform OWNS the env vars. App deploys use `update-function-code` (which
  # never touches env), so these persist across every deployment.
  # AWS_REGION is reserved — the runtime injects ap-south-1 automatically.
  environment {
    variables = {
      PORT                                   = "3000"
      NODE_ENV                               = "production"
      NOTIFICATION_QUEUE_URL_HIGH_PRIORITY   = aws_sqs_queue.main["high"].url
      NOTIFICATION_QUEUE_URL_MEDIUM_PRIORITY = aws_sqs_queue.main["medium"].url
      NOTIFICATION_QUEUE_URL_LOW_PRIORITY    = aws_sqs_queue.main["low"].url
    }
  }

  lifecycle {
    # Only the CODE artifact is owned by the NestJS deploy (update-function-code).
    # Handler + env stay managed here so Terraform keeps them correct.
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }
}

# Free HTTPS endpoint (no API Gateway cost).
# CORS is handled by the NestJS app (app.enableCors in src/lambda.ts), not here —
# setting it in both places emits duplicate Access-Control-Allow-Origin headers,
# which browsers reject.
resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function.api.function_name
  authorization_type = "NONE"
}

output "api_function_url" {
  description = "Public HTTPS endpoint for the NestJS backend"
  value       = aws_lambda_function_url.api.function_url
}
output "api_function_arn" {
  description = "ARN of the NestJS backend Lambda function"
  value       = aws_lambda_function.api.arn
}
