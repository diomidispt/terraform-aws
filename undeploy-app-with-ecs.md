# Tear down the go-app three-tier stack

Reverse of [deploy-app-with-ecs.md](deploy-app-with-ecs.md). Takes the running
**internet → ALB → ECS Fargate → RDS** app back to **~$0/month** while keeping every
piece of free scaffolding (VPC, subnets, IGW, state backend, ECR image, IAM/OIDC roles).

Account `298104300097` · region `us-east-1`.

---

## What actually costs money

Destroy in this order and the bill goes to roughly zero. The percentages are why the
order matters — **step 5 is over half the bill and it is the one people forget**, because
it is an `apply`, not a `destroy`.

| Step | Stack | Cost while running |
|------|-------|--------------------|
| 1 | `sauron-ecs-fargate` | ~$9/mo |
| 2 | `sauron-alb` | ~$16/mo |
| 3 | `sauron-rds` | ~$13/mo |
| 4 | `sauron-security-groups` | $0 (no charge — destroy for cleanliness) |
| 5 | **NAT gateway** (a VPC *apply*, not a destroy) | **~$32/mo + EIP** |

Kept, and free or pennies: VPC, subnets, route tables, IGW, ECR repository and images,
S3 + DynamoDB state backend, IAM and OIDC roles, the budget alarm.

---

## Order

```
ecs-fargate  →  alb  →  rds  →  security-groups  →  NAT off
```

Security groups must go **after** the resources that reference them, or the delete fails
with a dependency violation. ALB and RDS are independent of each other and can go in
either order.

---

## Option A — CI (`terraform-destroy.yml`)

Actions → **Terraform Destroy** → *Run workflow* → paste the `env_path` → approve the
`apply` environment. One run per stack, in order:

```
envs/sauron-ecs-fargate/DioProjects-us-east-1-sauron-ecs-fargate-DEV
envs/sauron-alb/DioProjects-us-east-1-sauron-alb-DEV
envs/sauron-rds/DioProjects-us-east-1-sauron-rds-DEV
envs/sauron-security-groups/DioProjects-us-east-1-sauron-security-groups-DEV
```

Wait for each to finish before starting the next. Then do **step 5** below — the NAT is
not covered by this workflow.

## Option B — local

```bash
aws sso login --profile sauron-admin
export AWS_PROFILE=sauron-admin AWS_REGION=us-east-1

for e in sauron-ecs-fargate sauron-alb sauron-rds sauron-security-groups; do
  echo "=== destroying $e ==="
  ( cd "envs/$e/DioProjects-us-east-1-$e-DEV" && terraform init -input=false && terraform destroy -auto-approve )
done
```

RDS takes ~3–5 minutes to delete. Everything else is quick.

---

## Step 5 — turn the NAT gateway off (the big one)

This is an **apply**, not a destroy. Do **not** run `terraform destroy` on
`envs/sauron-vpc` — that would delete the VPC, subnets, and IGW you want to keep.

1. In [`modules/solutions/vpc/main.tf`](modules/solutions/vpc/main.tf):
   - set the private route tables' `routes` back to `routes = []`
   - comment out the `module "nat_gateways"` block
2. Touch a comment in
   `envs/sauron-vpc/DioProjects-us-east-1-sauron-vpc-DEV/terraform.tfvars` — CI only
   detects `envs/**` changes, so a `modules/**`-only edit deploys nothing.
3. Commit to `main`, approve the apply. Or locally:
   ```bash
   ( cd envs/sauron-vpc/DioProjects-us-east-1-sauron-vpc-DEV && terraform apply )
   ```

Deleting the NAT gateway releases its Elastic IP automatically. An EIP that ends up
**unassociated** is billed (~$3.60/mo), so confirm it is gone in the checks below.

> Toggling NAT churns the public routes — the `route-tables` module keys routes by
> `count`, so they get replaced. Harmless when nothing is serving.

---

## Verify it actually reached ~$0

```bash
export AWS_PROFILE=sauron-admin AWS_REGION=us-east-1

# each of these should print nothing / None
aws ecs list-clusters --query clusterArns --output text
aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerName' --output text
aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' --output text
aws ec2 describe-nat-gateways --filter Name=state,Values=available,pending \
  --query 'NatGateways[].NatGatewayId' --output text

# must be empty - an unassociated EIP is billed
aws ec2 describe-addresses --query 'Addresses[?AssociationId==`null`].PublicIp' --output text

# should still exist - the free scaffolding we keep
aws ec2 describe-vpcs --filters Name=tag:Name,Values=sauron-DEV-VPC \
  --query 'Vpcs[].VpcId' --output text
aws ecr describe-images --repository-name go-app-dev --query 'length(imageDetails)'
```

Spend for the month, once the resources are gone:

```bash
aws ce get-cost-and-usage --time-period Start=$(date -u +%Y-%m-01),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY --metrics UnblendedCost \
  --query 'ResultsByTime[0].Total.UnblendedCost' --output json
```

Cost Explorer lags ~24h, so charges already incurred keep showing. What matters is that
the daily rate flattens after teardown.

---

## Gotchas

| Symptom | Cause | Fix |
|---|---|---|
| SG destroy: `DependencyViolation` | ALB/ECS/RDS still hold the SG | Destroy them first; ENI detach can lag a minute or two |
| NAT still billing after teardown | `modules/**` edited but no `envs/**` change | Touch the vpc env `terraform.tfvars` and re-apply |
| Charge continues after NAT is gone | EIP left allocated but unassociated | `aws ec2 release-address --allocation-id <id>` |
| RDS destroy leaves nothing to restore | `skip_final_snapshot = true` | Expected — **no backup is kept**. Set it to `false` first if you want one |
| State lock stuck after a cancelled run | DynamoDB lock not released | `terraform force-unlock <lock-id>` in that env folder |

---

## Standing it back up

Follow [deploy-app-with-ecs.md](deploy-app-with-ecs.md) forward: NAT on → `security-groups`
→ (`alb`, `rds`) → `ecs-fargate`.

**Every cross-stack ID in `terraform.tfvars` will be different after a teardown** and must
be re-wired: `alb_sg_id`, `ecs_sg_id`, `rds_sg_id`, `target_group_arn`, and the Secrets
Manager ARN. `DB_HOST` is the exception — RDS derives its endpoint from the instance
identifier, so the same hostname comes back.
