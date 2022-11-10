resource "aws_s3_bucket" "mcs-data-bucket" {
  bucket = "${var.resource_name_prefix}-mcs-data-bucket"
}

resource "aws_s3_bucket_acl" "mcs-data-bucket-acl" {
  bucket = aws_s3_bucket.mcs-data-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "mcs-data-bucket-public-access-block" {
  bucket                  = aws_s3_bucket.mcs-data-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
