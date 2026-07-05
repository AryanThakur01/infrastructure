locals {
  queues = {
    high = {
      max_concurrency    = 10
      visibility_timeout = 30
    }
    medium = {
      max_concurrency    = 5
      visibility_timeout = 30
    }
    low = {
      max_concurrency    = 2
      visibility_timeout = 30
    }
  }
}

resource "aws_sqs_queue" "dlq" {
  for_each = local.queues

  name                      = "${var.project_name}-${each.key}-dlq"
  message_retention_seconds = 1209600 # 14 days
}

resource "aws_sqs_queue" "main" {
  for_each = local.queues

  name                       = "${var.project_name}-${each.key}-queue"
  visibility_timeout_seconds = each.value.visibility_timeout # This value should be >= the max processing time of your Lambda function
  message_retention_seconds  = 1209600                       # 14 days
  receive_wait_time_seconds  = 20                            # Enable long polling to reduce empty responses and lower your cost per request
  redrive_policy = jsonencode({                              # Redrive policy for dead-letter queue
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = 3
  })
}
