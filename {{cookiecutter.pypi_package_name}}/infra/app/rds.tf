{% if cookiecutter.include_database == "yes" %}
{% raw %}
resource "random_password" "db" {
  length  = 32
  special = false
}

resource "aws_security_group" "_" {
  name        = "${var.project_name}-db"
  description = "Allow PostgreSQL from EB instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.security_group_id
  }

  tags = {
    Name = "${var.project_name}-db"
  }
}

resource "aws_db_subnet_group" "_" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.app_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_cloudwatch_log_group" "rds_postgresql" {
  name              = "/aws/rds/instance/${var.project_name}-db/postgresql"
  retention_in_days = 30
}

resource "aws_db_instance" "_" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_user
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group._.name
  vpc_security_group_ids = [aws_security_group._.id]

  deletion_protection       = true
  backup_retention_period   = 7
  storage_encrypted         = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-db-final-snapshot"
  copy_tags_to_snapshot     = true

  publicly_accessible = false

  tags = {
    Name      = "${var.project_name}-db"
    ManagedBy = "quick-app-template"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [password]
  }

  depends_on = [aws_cloudwatch_log_group.rds_postgresql]
}
{% endraw %}
{% endif %}
