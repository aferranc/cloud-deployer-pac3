resource "aws_s3_bucket" "bucket" {
  bucket = var.website_bucket_name
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.website_bucket_name}/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "bucket-website-config" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

#upload website files to s3:
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.bucket.id

  for_each     = fileset("uploads/", "*")
  key          = each.value
  source       = "uploads/${each.value}"
  etag         = filemd5("uploads/${each.value}")
  content_type = "text/html"

  depends_on = [
    aws_s3_bucket.bucket
  ]
}
