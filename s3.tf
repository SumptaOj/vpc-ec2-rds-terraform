resource "aws_s3_bucket" "user_data" {
  bucket = var.bucket_name
  acl = "private"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.user_data.id
  key    = "SamplePage.php"
  source = "web/SamplePage.php"
  etag   = filemd5("web/SamplePage.php")
}