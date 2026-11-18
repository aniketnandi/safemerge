# Secret containers only. Values are set with the AWS CLI, so they never
# appear in Git or in the Terraform state.
# recovery_window_in_days = 0 lets the stack be rebuilt with the same names after a lab reset.
resource "aws_secretsmanager_secret" "github_token" {
  name                    = "sm/github-token"
  description             = "GitHub token for reading PR code and posting comments and statuses"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "webhook_secret" {
  name                    = "sm/webhook-secret"
  description             = "Shared secret used to verify GitHub webhook signatures"
  recovery_window_in_days = 0
}
