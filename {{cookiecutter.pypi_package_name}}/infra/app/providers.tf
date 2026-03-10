terraform {
  required_version = ">= 1.10"

  backend "s3" {
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}
{% if cookiecutter.include_custom_domain == "yes" %}

# CloudFront requires ACM certificates in us-east-1, regardless of the app region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
{% endif %}
