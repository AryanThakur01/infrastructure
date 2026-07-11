data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "lambda_only" {
  statement {
    sid       = "AllowOnlyTheLambdaRole"
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_execution_role.arn]
    }
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
  statement {
    sid       = "DenyEveryoneElse"
    effect    = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["dynamodb:*"]
    resources = [
      aws_dynamodb_table.lab.arn,
      "${aws_dynamodb_table.lab.arn}/index/*"
    ]
    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = [
        aws_iam_role.lambda_execution_role.arn,
        data.aws_caller_identity.current.arn
      ]
    }
  }
}

# Create the DynamoDB table for the lab
resource "aws_dynamodb_table" "lab" {
  name         = var.project_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "sk"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  # TTL: items with an expiry epoch in `expires_at` get auto-deleted.
  # Handy for lab data that shouldn't live forever. Optional — remove if unwanted.
  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  # Recommended even for labs — protects against fat-fingered deletes.
  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true # AWS-owned key; switch to a CMK if you need one
  }
}
resource "aws_dynamodb_resource_policy" "lambda_only" {
  resource_arn = aws_dynamodb_table.lab.arn
  policy = data.aws_iam_policy_document.lambda_only.json
}
