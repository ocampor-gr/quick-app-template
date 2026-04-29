{% raw %}
resource "aws_iam_openid_connect_provider" "_" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider._.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "_" {
  name               = "${var.project_name}-github-actions-deploy"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "deploy" {
  # State bucket: full read, write objects, delete objects (terraform's
  # S3 backend releases tflock via DeleteObject; without it the first
  # apply leaves a stale lock and every subsequent apply blocks).
  # PutObjectAcl is required by EB's internal version-copy step that
  # ACLs the runtime _versions zip under the caller's principal.
  statement {
    sid    = "S3StateAndAppVersionsWrite"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
    ]
    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*",
    ]
  }

  # EB-managed buckets (e.g. app-version zips, pipeline artifacts).
  # Read-only — the deploy pushes zips through the EB API, not S3 PUT.
  statement {
    sid    = "S3EBManagedRead"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [
      "arn:aws:s3:::elasticbeanstalk-*",
      "arn:aws:s3:::elasticbeanstalk-*/*",
    ]
  }

  statement {
    sid    = "ElasticBeanstalkRead"
    effect = "Allow"
    actions = [
      "elasticbeanstalk:Describe*",
      "elasticbeanstalk:List*",
      "elasticbeanstalk:ValidateConfigurationSettings",
      "elasticbeanstalk:CheckDNSAvailability",
    ]
    resources = ["*"]
  }

  # Only the writes a steady-state rollout actually performs. Notably
  # includes DeleteApplicationVersion — Terraform's
  # aws_elastic_beanstalk_application_version destroys the previous
  # version on every new release.
  statement {
    sid    = "ElasticBeanstalkDeploy"
    effect = "Allow"
    actions = [
      "elasticbeanstalk:CreateApplicationVersion",
      "elasticbeanstalk:DeleteApplicationVersion",
      "elasticbeanstalk:UpdateEnvironment",
      "elasticbeanstalk:AddTags",
    ]
    resources = ["*"]
  }

  # EB's UpdateEnvironment dispatches to CloudFormation against its
  # internally-managed stack under the caller's principal (not the EB
  # service role). Scope to awseb-* to keep this from being an
  # account-wide foot-cannon.
  statement {
    sid       = "CloudFormationEBStackUpdate"
    effect    = "Allow"
    actions   = ["cloudformation:UpdateStack"]
    resources = ["arn:aws:cloudformation:*:*:stack/awseb-*/*"]
  }

  # EB suspends/resumes ASG processes around rolling deploys.
  statement {
    sid    = "AutoScalingDeploy"
    effect = "Allow"
    actions = [
      "autoscaling:SuspendProcesses",
      "autoscaling:ResumeProcesses",
    ]
    resources = ["arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/awseb-*"]
  }

  # Refresh-only — Terraform plan reads every resource in state on each
  # run. No mutating actions here.
  statement {
    sid    = "ReadOnlyRefresh"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "autoscaling:Describe*",
      "elasticloadbalancing:Describe*",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:GetInstanceProfile",
      "iam:ListInstanceProfilesForRole",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "rds:Describe*",
      "rds:ListTagsForResource",
      "cloudformation:Describe*",
      "cloudformation:List*",
      "cloudformation:GetTemplate*",
      "logs:Describe*",
      "logs:List*",
      "logs:ListTagsForResource",
      "cloudwatch:Describe*",
      "cloudwatch:List*",
      "sns:Get*",
      "sns:List*",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListResourceTags",
      "ssm:DescribeParameters",
    ]
    resources = ["*"]
  }

  # SSM Parameter Store: read + write + delete for parameters under
  # the project prefix. Write is needed because the deploy workflow
  # re-applies Terraform every push, and any change to a secret
  # value (rotated GH secret, new admin email) flows through here.
  # Scope is path-restricted so cross-project parameters stay
  # inaccessible.
  statement {
    sid    = "SSMProjectParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:DeleteParameters",
      "ssm:LabelParameterVersion",
      "ssm:AddTagsToResource",
      "ssm:RemoveTagsFromResource",
      "ssm:ListTagsForResource",
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/${var.project_name}/*",
    ]
  }
{% endraw %}
{% if cookiecutter.include_custom_domain == "yes" %}
{% raw %}

  # Custom domain: the EB env is fronted by a Route 53 hosted zone and
  # an ACM cert. Refresh of those needs Route 53 / ACM read.
  statement {
    sid    = "Route53Read"
    effect = "Allow"
    actions = [
      "route53:Get*",
      "route53:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ACMRead"
    effect = "Allow"
    actions = [
      "acm:Describe*",
      "acm:List*",
    ]
    resources = ["*"]
  }
{% endraw %}
{% endif %}
{% raw %}

  # PassRole is the standard AWS privilege-escalation primitive — with
  # Resource "*" the deploy role could attach any account-wide role
  # (e.g. a break-glass admin) to any compute service it has the
  # matching Create/Update permission for. Scope to the project's own
  # EB roles and restrict the consuming service to EB / EC2.
  statement {
    sid       = "IAMPassRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::*:role/${var.project_name}-*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
      ]
    }
  }

  statement {
    sid       = "STS"
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "_" {
  name   = "${var.project_name}-github-actions-deploy"
  role   = aws_iam_role._.id
  policy = data.aws_iam_policy_document.deploy.json
}
{% endraw %}
