

resource "aws_api_gateway_rest_api" "messages_api" {
  name = "messages-api"
}

resource "aws_api_gateway_resource" "message" {
  parent_id   = aws_api_gateway_rest_api.messages_api.root_resource_id
  path_part   = "message"
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
}

resource "aws_api_gateway_method" "message" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.message.id
  rest_api_id   = aws_api_gateway_rest_api.messages_api.id
}

resource "aws_api_gateway_integration" "message" {
  http_method = aws_api_gateway_method.message.http_method
  resource_id = aws_api_gateway_resource.message.id
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  type = "AWS"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/PutItem"
  credentials = aws_iam_role.messages_api_role.arn
}