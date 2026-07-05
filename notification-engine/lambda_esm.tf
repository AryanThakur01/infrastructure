locals {
  function_names = {
    process_sqs_event = "process_sqs_event"
  }
}

resource "aws_lambda_event_source_mapping" "worker" {
  for_each = local.queues

  event_source_arn        = aws_sqs_queue.main[each.key].arn                                                 # the queue
  function_name           = aws_lambda_function.lambda[local.function_names.process_sqs_event].function_name # the lambda function
  batch_size              = 10
  function_response_types = ["ReportBatchItemFailures"]

  scaling_config {
    maximum_concurrency = each.value.max_concurrency
  }
}
