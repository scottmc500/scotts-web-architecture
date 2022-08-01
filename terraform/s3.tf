# S3 bucket for website.
resource "aws_s3_bucket" "www_bucket" {
  bucket = "www.${var.bucket_name}"
  policy = templatefile("templates/s3-policy.json", { bucket = "www.${var.bucket_name}" })
  tags = var.common_tags
}

resource "aws_s3_bucket_acl" "www_bucket_acl" {
  bucket = aws_s3_bucket.www_bucket.id
  acl = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "www_bucket_cors" {
  bucket = aws_s3_bucket.www_bucket.id
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${var.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "www_bucket_website" {
  bucket = aws_s3_bucket.www_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_logging" "www_bucket_logging" {
  bucket = aws_s3_bucket.www_bucket.id
  target_bucket = aws_s3_bucket.logs_bucket.id
  target_prefix = "logs/"
}

# S3 bucket for redirecting non-www to www.
resource "aws_s3_bucket" "root_bucket" {
  bucket = var.bucket_name
  policy = templatefile("templates/s3-policy.json", { bucket = var.bucket_name })
  tags = var.common_tags
}

resource "aws_s3_bucket_acl" "root_bucket_acl" {
  bucket = aws_s3_bucket.root_bucket.id
  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "root_bucket_website" {
  bucket = aws_s3_bucket.root_bucket.id
  redirect_all_requests_to {
    host_name = "https://www.${var.domain_name}"
  }
}

# S3 bucket for capturing logs
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "logs.${var.bucket_name}"
}

resource "aws_s3_bucket_acl" "logs_bucket_acl" {
  bucket = aws_s3_bucket.logs_bucket.id
  acl = "log-delivery-write"
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_bucket_lifecycle" {
  bucket = aws_s3_bucket.logs_bucket.id
  rule {
    id      = "logs"
    filter {
      prefix  = "logs/"
    }
    status = "Enabled"
    expiration {
      days = 90
    }
  }
}

output "resume_endpoint" {
  value = "https://s3.${var.aws_region}.amazonaws.com/${aws_s3_bucket.www_bucket.bucket}/mchenry-scott-resume.pdf"
}