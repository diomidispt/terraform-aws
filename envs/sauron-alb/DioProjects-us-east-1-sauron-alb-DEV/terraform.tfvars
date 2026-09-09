env_name          = "sauron"
env_type          = "DEV"
alb_sg_id         = "sg-097f449e2ef434236" # sauron-security-groups output: alb_sg_id
target_port       = 8080
health_check_path = "/health"
