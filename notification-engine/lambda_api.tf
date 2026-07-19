resource "aws_iam_role" "api_execution_role" {
  name               = "${var.project_name}-api-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_basic" {
  role       = aws_iam_role.api_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "api" {
  filename      = "${path.module}/functions/zips/api.zip"
  function_name = "${var.project_name}-api"
  role          = aws_iam_role.api_execution_role.arn
  handler       = "dist/lambda.handler" # placeholder; NestJS deploy sets its real handler once
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
    # Code + handler are owned by the NestJS deploy; env stays managed here.
    ignore_changes = [
      filename,
      source_code_hash,
      handler,
    ]
  }
}

# Free HTTPS endpoint (no API Gateway cost).
resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function.api.function_name
  authorization_type = "NONE"

  cors {
    allow_origins  = ["https://www.aryanthakur.dev", "https://aryanthakur.dev"]
    allow_methods  = ["*"]
    allow_headers  = ["*"]
    expose_headers = ["*"]
    max_age        = 86400
  }
}

output "api_function_url" {
  description = "Public HTTPS endpoint for the NestJS backend"
  value       = aws_lambda_function_url.api.function_url
}
output "api_function_arn" {
  description = "ARN of the NestJS backend Lambda function"
  value       = aws_lambda_function.api.arn
}
