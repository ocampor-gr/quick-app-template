{% if cookiecutter.include_database == "yes" %}
{% raw %}
resource "aws_security_group" "_" {
  name        = "${var.project_name}-db"
  description = "Allow PostgreSQL from EB instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.security_group_id]
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

resource "aws_db_instance" "_" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = "postgres"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group._.name
  vpc_security_group_ids = [aws_security_group._.id]

  skip_final_snapshot = true
  publicly_accessible = false

  tags = {
    Name = "${var.project_name}-db"
  }
}
{% endraw %}
{% endif %}
