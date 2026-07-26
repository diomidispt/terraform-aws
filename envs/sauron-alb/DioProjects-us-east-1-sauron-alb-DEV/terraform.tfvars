env_name          = "sauron"
env_type          = "DEV"
alb_sg_id         = "sg-03bbd25940bcd72af" # sauron-security-groups output: alb_sg_id
target_port       = 8080
health_check_path = "/health"
