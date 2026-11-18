output "scan_jobs_url" {
  value = aws_sqs_queue.scan_jobs.url
}

output "scan_jobs_arn" {
  value = aws_sqs_queue.scan_jobs.arn
}

output "scan_jobs_dlq_url" {
  value = aws_sqs_queue.scan_jobs_dlq.url
}

output "scan_jobs_dlq_arn" {
  value = aws_sqs_queue.scan_jobs_dlq.arn
}
