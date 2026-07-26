env_name         = "sauron"
env_type         = "DEV"
ecs_sg_id        = "sg-0eb83c85ea5f8592e"                                                                           # sauron-security-groups output: ecs_sg_id
target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:298104300097:targetgroup/sauron-dev-tg/21f3fab143f846cc" # sauron-alb output
ecr_image        = "298104300097.dkr.ecr.us-east-1.amazonaws.com/go-app-dev:latest"
container_port   = 8080

# Plain env vars the go-app reads (internal/config/db.go, cmd/api/main.go).
# Static values are set; DB_HOST comes from the sauron-rds output after Wave 2.
environment_variables = [
  { name = "PORT", value = "8080" },
  { name = "DB_HOST", value = "sauron-dev-db.cm720k2kg8tf.us-east-1.rds.amazonaws.com" }, # sauron-rds output: address
  { name = "DB_PORT", value = "5432" },
  { name = "DB_NAME", value = "pharma" },
  { name = "DB_USER", value = "rootdba" },
]

# DB_PASSWORD injected from the RDS-managed Secrets Manager secret (JSON key "password").
# valueFrom syntax: <secret-arn>:<json-key>::   → fill the ARN from the sauron-rds output.
secrets = [
  { name = "DB_PASSWORD", valueFrom = "arn:aws:secretsmanager:us-east-1:298104300097:secret:rds!db-e4e0a9d1-9a2d-414b-89f4-754a1cdcb4f6-s6jYM4:password::" },
]

# ARN the ECS execution role is allowed to read (same secret ARN as above).
secret_arns = ["arn:aws:secretsmanager:us-east-1:298104300097:secret:rds!db-e4e0a9d1-9a2d-414b-89f4-754a1cdcb4f6-s6jYM4"]
