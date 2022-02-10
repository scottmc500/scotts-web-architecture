resource "aws_dynamodb_table" "messages-dynamodb-table" {
  name           = "Messages"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "email"
  range_key      = "timestamp"
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