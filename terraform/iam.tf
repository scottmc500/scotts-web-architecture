resource "aws_iam_role" "messages_api_role" {
    name = "messages_api_role"
    assume_role_policy = templatefile("templates/api-gateway-policy.json", { bucket = var.bucket_name })
}

resource "aws_iam_role" "messages_lambda_role" {
    name = "messages_lambda_role"
    assume_role_policy = templatefile("templates/lambda-policy.json", { bucket = var.bucket_name })
}

resource "aws_iam_role_policy_attachment" "api_gateway_dynamodb_policy_attach" {
  role       = aws_iam_role.messages_api_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attach" {
    role = aws_iam_role.messages_lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attach" {
    role = aws_iam_role.messages_lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sns_policy_attach" {
    role = aws_iam_role.messages_lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attach" {
    role = aws_iam_role.messages_lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}