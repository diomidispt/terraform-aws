env_name = "sauron"
env_type = "DEV"

# NAT gateway re-enabled in the vpc solution module on 2026-09-09 so ECS tasks in
# the private subnets can reach ECR / Secrets Manager / CloudWatch. This comment
# also re-triggers CI for the vpc env, since module-only changes aren't detected.
vpc = {
  cidr_block = "10.0.0.0/20"
}
