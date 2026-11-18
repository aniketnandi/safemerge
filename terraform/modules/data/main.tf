# Per-repo settings: severity threshold, staging allowlist, alert email
resource "aws_dynamodb_table" "repos" {
  name         = "${var.prefix}-repos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "repo"

  attribute {
    name = "repo"
    type = "S"
  }
}

# Scan history. Sort key "scanKey" = scanTime#scanId, so a query returns scans in time order.
resource "aws_dynamodb_table" "scans" {
  name         = "${var.prefix}-scans"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "repo"
  range_key    = "scanKey"

  attribute {
    name = "repo"
    type = "S"
  }
  attribute {
    name = "scanKey"
    type = "S"
  }
  attribute {
    name = "repoPr"
    type = "S"
  }
  attribute {
    name = "scanTime"
    type = "S"
  }

  # Latest scan for a pull request: repoPr = "owner/repo#42"
  global_secondary_index {
    name            = "byPr"
    hash_key        = "repoPr"
    range_key       = "scanTime"
    projection_type = "ALL"
  }

  # Old scans expire automatically (the app sets ttl to now + 90 days)
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

# Findings baseline. Sort key "findingKey" = filePath#fingerprint,
# so begins_with(filePath) returns all findings for one file.
resource "aws_dynamodb_table" "findings" {
  name         = "${var.prefix}-findings"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "repo"
  range_key    = "findingKey"

  attribute {
    name = "repo"
    type = "S"
  }
  attribute {
    name = "findingKey"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}
