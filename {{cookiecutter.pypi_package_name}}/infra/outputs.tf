{% raw %}
output "eb_app_name" {
  description = "Elastic Beanstalk application name"
  value       = aws_elastic_beanstalk_application._.name
}

output "eb_environment_name" {
  description = "Elastic Beanstalk environment name"
  value       = aws_elastic_beanstalk_environment._.name
}

output "eb_environment_cname" {
  description = "Elastic Beanstalk environment CNAME"
  value       = aws_elastic_beanstalk_environment._.cname
}

output "eb_environment_url" {
  description = "Elastic Beanstalk environment URL"
  value       = "http://${aws_elastic_beanstalk_environment._.cname}"
}

output "s3_app_versions_bucket" {
  description = "S3 bucket for application versions"
  value       = aws_s3_bucket._.id
}
{% endraw %}
{% if cookiecutter.include_database == "yes" %}

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance._.endpoint
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance._.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance._.db_name
}
{% endif %}
