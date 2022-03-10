resource "aws_dynamodb_table" "messages-dynamodb-table" {
  name             = "Messages"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "email"
  range_key        = "timestamp"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

resource "aws_sns_topic" "messaging_topic" {
  name = "smm-message-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.messaging_topic.arn
  protocol  = "email"
  endpoint  = "smchenry2014@gmail.com"
}

resource "aws_sqs_queue" "messaging_dlq" {
  name = "smm-message-dlq"
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "lambdas/lambda_function.py"
  output_path = "output/lambda.zip"
}

resource "aws_lambda_function" "message_listener" {
  filename         = data.archive_file.lambda_package.output_path
  function_name    = "db-message-listener"
  role             = aws_iam_role.messages_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.messaging_topic.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "lambda_dynamodb_mapping" {
  function_name                 = aws_lambda_function.message_listener.arn
  event_source_arn              = aws_dynamodb_table.messages-dynamodb-table.stream_arn
  starting_position             = "LATEST"
  maximum_record_age_in_seconds = 60
  maximum_retry_attempts        = 2
  destination_config {
    on_failure {
      destination_arn = aws_sqs_queue.messaging_dlq.arn
    }
  }
}