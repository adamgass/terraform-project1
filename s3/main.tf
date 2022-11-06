resource "aws_s3_bucket_policy" "eks_alb_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket_logging.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::127311923021:root"
      },
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.s3_bucket_logging.id}/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "s3_bucket_logging" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_acl" "s3_bucket_logging_acl" {
  bucket = aws_s3_bucket.s3_bucket_logging.id
  acl    = "private"
}

resource "aws_s3_bucket_object" "Images" {
  bucket = aws_s3_bucket.s3_bucket_logging.id
  key    = "Images/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "Logs" {
  bucket = aws_s3_bucket.s3_bucket_logging.id
  key    = "Logs/"
  source = "/dev/null"
}