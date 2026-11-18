output "repos_table" {
  value = aws_dynamodb_table.repos.name
}

output "scans_table" {
  value = aws_dynamodb_table.scans.name
}

output "findings_table" {
  value = aws_dynamodb_table.findings.name
}
