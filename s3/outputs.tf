output "alb_s3_bucket" {
    value = aws_s3_bucket.s3_bucket_logging.id
}