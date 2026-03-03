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

{% endraw %}
{% if cookiecutter.include_custom_domain == "yes" %}
{% raw %}

output "app_url" {
  description = "Application URL"
  value       = "https://${local.fqdn}"
}

output "nameservers" {
  description = "Route 53 nameservers (update your domain registrar with these; empty if using existing zone)"
  value       = local.create_zone ? aws_route53_zone._[0].name_servers : []
}
{% endraw %}
{% endif %}
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
