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
{% if cookiecutter.include_database == "yes" %}
variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = "vpc-0865d0fe1685e07c6"
}

variable "subnet_ids" {
  description = "Existing subnet IDs (multi-AZ) for the DB subnet group"
  type        = list(string)
  default     = ["subnet-0f51fe4df99eafc89", "subnet-09ed0579b716d86e3"]
}

variable "security_group_id" {
  description = "Existing security group ID for the RDS instance"
  type        = string
  default     = "sg-01b0628a487f58d2b"
}

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
