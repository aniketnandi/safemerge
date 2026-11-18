output "github_token_arn" {
  value = aws_secretsmanager_secret.github_token.arn
}

output "webhook_secret_arn" {
  value = aws_secretsmanager_secret.webhook_secret.arn
}
