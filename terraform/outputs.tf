output "account_id" {
  value = data.aws_caller_identity.me.account_id
}

output "lab_role_arn" {
  value = data.aws_iam_role.lab.arn
}

output "scan_jobs_queue_url" {
  value = module.queues.scan_jobs_url
}

output "scan_jobs_dlq_url" {
  value = module.queues.scan_jobs_dlq_url
}

output "repos_table" {
  value = module.data.repos_table
}

output "scans_table" {
  value = module.data.scans_table
}

output "findings_table" {
  value = module.data.findings_table
}

output "reports_bucket" {
  value = module.reports.bucket_name
}
