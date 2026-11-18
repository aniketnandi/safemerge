output "bucket_name" {
  value = data.aws_s3_bucket.reports.id
}

output "bucket_arn" {
  value = data.aws_s3_bucket.reports.arn
}
