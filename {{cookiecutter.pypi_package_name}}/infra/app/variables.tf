variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "{{ cookiecutter.pypi_package_name }}"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "app_subnet_ids" {
  description = "Existing subnet IDs (multi-AZ) for app instances"
  type        = list(string)
}

variable "security_group_id" {
  description = "Existing security group ID for EB instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for EB environment"
  type        = string
  default     = "t4g.small"
}

variable "eb_app_name" {
  description = "Elastic Beanstalk application name"
  type        = string
}

variable "eb_environment_name" {
  description = "Elastic Beanstalk environment name"
  type        = string
  default     = "{{ cookiecutter.eb_environment }}"
}

variable "solution_stack_name" {
  description = "EB solution stack (ARM64)"
  type        = string
  default     = "64bit Amazon Linux 2023 v4.9.3 running Docker"
}

variable "google_client_id" {
  description = "Google OAuth client ID"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  sensitive   = true
}

variable "allowed_domain" {
  description = "Allowed email domain for OAuth"
  type        = string
  default     = "graphitehq.com"
}

variable "tf_state_bucket" {
  description = "Shared S3 bucket for Terraform state and app versions"
  type        = string
  default     = ""
}

variable "ssm_prefix" {
  description = "SSM Parameter Store path prefix for secrets"
  type        = string
  default     = "/{{ cookiecutter.pypi_package_name }}"
}

variable "app_version_label" {
  description = "Application version label for deployment (empty = infra only)"
  type        = string
  default     = ""
}
{% if cookiecutter.include_custom_domain == "yes" %}

variable "domain_name" {
  description = "Root domain name (e.g., example.com)"
  type        = string
  default     = "{{ cookiecutter.domain_name }}"
}

variable "subdomain" {
  description = "Subdomain prefix (e.g., \"app\"). Leave empty for bare domain."
  type        = string
  default     = "{{ cookiecutter.subdomain }}"
}
{% endif %}
{% if cookiecutter.include_database == "yes" %}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_user" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "{{ cookiecutter.project_slug }}"
}
{% endif %}
