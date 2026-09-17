env_name = "sauron"
env_type = "DEV"

# NAT gateway re-enabled in the vpc solution module on 2026-09-09 so ECS tasks in
# the private subnets can reach ECR / Secrets Manager / CloudWatch. This comment
# also re-triggers CI for the vpc env, since module-only changes aren't detected.
vpc = {
  cidr_block = "10.0.0.0/20"
}

# NAT gateway turned off 2026-09-17 after the meetup demo (see undeploy-app-with-ecs.md step 5).
