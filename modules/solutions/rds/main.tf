resource "aws_db_subnet_group" "this" {
  name        = "${lower(var.env_name)}-${lower(var.env_type)}-db"
  description = "DB subnet group for ${var.env_name}-${var.env_type}"
  subnet_ids  = var.subnet_ids
}

resource "aws_db_instance" "this" {
  identifier             = "${lower(var.env_name)}-${lower(var.env_type)}-db"
  instance_class         = var.db.instance_class
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false

  engine         = var.db.engine
  engine_version = var.db.engine_version
  db_name        = var.db.name
  username       = var.db.username
  password       = var.db.password

  allocated_storage = var.db.allocated_storage
  storage_type      = "gp2"
  storage_encrypted = false

  multi_az                = false
  backup_retention_period = var.db.backup_retention_period
  skip_final_snapshot     = var.db.skip_final_snapshot
  deletion_protection     = var.db.deletion_protection
  apply_immediately       = true
}
