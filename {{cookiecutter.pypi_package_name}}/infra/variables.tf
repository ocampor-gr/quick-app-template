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
  description = "Existing subnet IDs (multi-AZ) for app instances and DB subnet group"
  type        = list(string)
}

variable "elb_subnet_ids" {
  description = "Existing subnet IDs (multi-AZ) for the load balancer"
  type        = list(string)
}

variable "security_group_id" {
  description = "Existing security group ID for instances and RDS"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for EB environment"
  type        = string
  default     = "t3.large"
}

variable "eb_app_name" {
  description = "Elastic Beanstalk application name"
  type        = string
  default     = "{{ cookiecutter.eb_app_name }}"
}

variable "eb_environment_name" {
  description = "Elastic Beanstalk environment name"
  type        = string
  default     = "{{ cookiecutter.eb_environment }}"
}

variable "solution_stack_name" {
  description = "EB solution stack"
  type        = string
  default     = "64bit Amazon Linux 2 running Docker"
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

variable "auth_secret" {
  description = "Secret key for authentication"
  type        = string
  sensitive   = true
}

variable "allowed_domain" {
  description = "Allowed email domain for OAuth"
  type        = string
  default     = "graphitehq.com"
}
{% if cookiecutter.include_database == "yes" %}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "{{ cookiecutter.project_slug }}"
}
{% endif %}
