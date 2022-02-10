resource "aws_sns_topic" "messaging_topic" {
    name = "smm-message-topic"
}

data "archive_file" "lambda_package" {
    type = "zip"
    source_file = "lambdas/lambda_function.py"
    output_path = "output/lambda.zip"
}

resource "aws_lambda_function" "message_listener" {
    filename = "output/lambda.zip"
    function_name = "db-message-listener"
    role = aws_iam_role.messages_lambda_role.arn
    handler = "lambda_function.lambda_handler"
    runtime = "python3.8"
    environment {
        variables = {
            TOPIC_ARN = aws_sns_topic.messaging_topic.arn
        }
    }
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = aws_dynamodb_table.messages-dynamodb-table.stream_arn
  function_name     = aws_lambda_function.message_listener.arn
  starting_position = "LATEST"
}