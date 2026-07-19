// Variables you need to set
locals {
  github_repos       = ["AryanThakur01/personal-portfolio", "AryanThakur01/notification-engine"]
  github_thumbprint = "6938fd4d98bab03faadb97b34396831e3780aea1" // GitHub's OIDC thumbprint (rotate if GitHub changes it)
}

// 1. OIDC provider — tells AWS to trust GitHub's token issuer (create ONCE per account; if you already have it, import or reuse)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.github_thumbprint]
}

// 2. Trust policy — WHO may assume the role (only your repo's workflows)
data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [for repo in local.github_repos : "repo:${repo}:ref:refs/heads/prod"]
    }
  }
}

// 3. The role itself
resource "aws_iam_role" "github_deploy" {
  name               = "github-deploy-portfolio"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

// 4. Permissions policy — WHAT the role may do (S3 only, no invalidation)
data "aws_iam_policy_document" "deploy_permissions" {
  statement {
    sid       = "ListBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.portfolio.arn] // bucket ARN, no /*
  }

  statement {
    sid       = "WriteObjects"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.portfolio.arn}/*"] // objects, with /*
  }

  statement {
    sid       = "UpdateLambdaFunctionCode"
    actions   = ["lambda:UpdateFunctionCode"]
    resources = ["arn:aws:lambda:ap-south-1:980989823308:function:notification-engine-api"] // notification engine lambda function ARN
  }
}

resource "aws_iam_role_policy" "deploy" {
  name   = "portfolio-deploy"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.deploy_permissions.json
}

// 5. Output the role ARN — paste into your workflow's role-to-assume
output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}
