resource "aws_api_gateway_rest_api" "messages_api" {
  name = "messages-api"
}

resource "aws_api_gateway_resource" "message" {
  parent_id   = aws_api_gateway_rest_api.messages_api.root_resource_id
  path_part   = "message"
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
}

module "cors" {
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.1"
  api      = aws_api_gateway_rest_api.messages_api.id
  resource = aws_api_gateway_resource.message.id
  methods = ["POST"]
}

resource "aws_api_gateway_method" "message_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.message.id
  rest_api_id   = aws_api_gateway_rest_api.messages_api.id
  api_key_required = true
}

resource "aws_api_gateway_integration" "message_post" {
  http_method = aws_api_gateway_method.message_post.http_method
  resource_id = aws_api_gateway_resource.message.id
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  type = "AWS"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/PutItem"
  credentials = aws_iam_role.messages_api_role.arn
}

resource "aws_api_gateway_method_response" "message_post" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  resource_id = aws_api_gateway_resource.message.id
  http_method = aws_api_gateway_method.message_post.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "message_post" {
  depends_on = [aws_api_gateway_integration.message_post]
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  resource_id = aws_api_gateway_resource.message.id
  http_method = aws_api_gateway_method.message_post.http_method
  status_code = aws_api_gateway_method_response.message_post.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Requested-With'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
  }
}

resource "aws_api_gateway_deployment" "message" {
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.messages_api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.message.id
  rest_api_id = aws_api_gateway_rest_api.messages_api.id
  stage_name = "default"
}

resource "aws_api_gateway_api_key" "messages_key" {
  name = "messages_key"
}

resource "aws_api_gateway_usage_plan" "messages_usage_plan" {
  name = "messages_usage_plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.messages_api.id
    stage = aws_api_gateway_stage.default.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "messages_usage_plan_key" {
  key_id = aws_api_gateway_api_key.messages_key.id
  key_type = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.messages_usage_plan.id
}

output "api_key_value" {
  value = aws_api_gateway_api_key.messages_key.value
  sensitive = true
}

output "api_endpoint" {
  value = "${aws_api_gateway_deployment.message.invoke_url}${aws_api_gateway_stage.default.stage_name}${aws_api_gateway_resource.message.path}"
}