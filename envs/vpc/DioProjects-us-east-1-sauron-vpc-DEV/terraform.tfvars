env_name = "sauron"
env_type = "DEV"

# NAT gateway enabled in the vpc solution module (private subnets -> internet
# for ECR pulls / Secrets Manager / CloudWatch). This comment re-triggers CI
# for the vpc env, since module-only changes aren't detected.
vpc = {
  cidr_block = "10.0.0.0/20"
}

