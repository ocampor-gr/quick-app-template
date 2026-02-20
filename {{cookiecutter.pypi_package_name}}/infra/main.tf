{% raw %}
resource "aws_elastic_beanstalk_application" "_" {
  name        = var.eb_app_name
  description = "${var.project_name} application"

  appversion_lifecycle {
    service_role          = aws_iam_role.eb_service.arn
    max_count             = 10
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_environment" "_" {
  name                = var.eb_environment_name
  application         = aws_elastic_beanstalk_application._.name
  solution_stack_name = var.solution_stack_name

  # VPC
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.app_subnet_ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.elb_subnet_ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  # Instances
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile._.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.security_group_id
  }

  # Service role
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.eb_service.arn
  }

  # Load balancer
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  # Environment variables
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "GOOGLE_CLIENT_ID"
    value     = var.google_client_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "GOOGLE_CLIENT_SECRET"
    value     = var.google_client_secret
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AUTH_SECRET"
    value     = var.auth_secret
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ALLOWED_DOMAIN"
    value     = var.allowed_domain
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEV_AUTH"
    value     = "false"
  }
{% endraw %}
{% if cookiecutter.include_database == "yes" %}
{% raw %}

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_HOST"
    value     = aws_db_instance._.address
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PORT"
    value     = tostring(aws_db_instance._.port)
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_NAME"
    value     = aws_db_instance._.db_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_USER"
    value     = aws_db_instance._.username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_PASS"
    value     = var.db_password
  }
{% endraw %}
{% endif %}
{% raw %}

  tags = {
    Name = "${var.project_name}-eb-env"
  }
}

resource "terraform_data" "_" {
  triggers_replace = {
    environment_cname = aws_elastic_beanstalk_environment._.cname
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws elasticbeanstalk update-environment \
        --environment-name ${aws_elastic_beanstalk_environment._.name} \
        --option-settings "Namespace=aws:elasticbeanstalk:application:environment,OptionName=AUTH_URL,Value=http://${aws_elastic_beanstalk_environment._.cname}" \
        --region ${var.region}
    EOT
  }
}
{% endraw %}
