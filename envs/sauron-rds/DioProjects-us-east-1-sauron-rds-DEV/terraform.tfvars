env_name  = "sauron"
env_type  = "DEV"
rds_sg_id = "sg-0dd8eb6457a6c66fd" # sauron-security-groups output: rds_sg_id

db = {
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = "db.t3.micro"
  name                    = "pharma"
  username                = "rootdba"
  allocated_storage       = 20
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
}
