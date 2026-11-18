# Dead-letter queue: holds scan jobs that failed 3 times.
# Kept 14 days (the maximum) so failures can be investigated.
resource "aws_sqs_queue" "scan_jobs_dlq" {
  name                      = "${var.prefix}-scan-jobs-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

# Main scan job queue. The webhook Lambda sends jobs here, the SAST worker reads them.
resource "aws_sqs_queue" "scan_jobs" {
  name                       = "${var.prefix}-scan-jobs"
  # A job is hidden from other workers for 6 minutes while one worker scans it.
  # Must be longer than the SAST worker Lambda timeout (5 minutes).
  visibility_timeout_seconds = 360
  message_retention_seconds  = 345600 # 4 days
  sqs_managed_sse_enabled    = true

  # After 3 failed attempts, move the job to the dead-letter queue
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.scan_jobs_dlq.arn
    maxReceiveCount     = 3
  })
}
