# Deploy the go-app three-tier stack (ECS Fargate)

Runbook to stand up the **internet → ALB → ECS Fargate → RDS** app from the
already-existing foundation (VPC, ECR, state backend, OIDC CI role).

```
Internet ──80──> ALB (public subnets) ──8080──> ECS Fargate task (private subnets) ──5432──> RDS (private subnets)
                                                        │
                                                        └─443─> NAT ─> ECR / Secrets Manager / CloudWatch
```

Account `298104300097` · region `us-east-1` · VPC `sauron-DEV-VPC`.

---

## Why the order matters

The stacks feed each other through **manually-wired tfvars** (no
`terraform_remote_state`). Each stack exposes what the next needs via an env-level
`outputs.tf` (+ a `common.outputs.tf` symlink). CI change-detection only fires on
**`envs/**`** paths, so a `modules/**`-only change needs an `envs/**` touch to deploy.

**Deploy order:** `security-groups` → (`alb`, `rds`) → `ecs-fargate`, with **NAT**
enabled on the VPC before ECS. **Teardown is the reverse.**

## Prerequisites

```bash
aws sso login --profile sauron-admin      # local applies
export AWS_PROFILE=sauron-admin AWS_REGION=us-east-1
```
Already deployed and assumed present: `envs/vpc` (VPC + public/private subnets + IGW),
`envs/sauron-ecr` (`go-app-dev` repo), state backend, `github-actions-ci` OIDC role.

Two ways to apply each stack:
- **CI (recommended):** commit to `main` → pipeline runs `plan` → **approve the `apply`
  environment** in GitHub Actions. (Push a `modules/**`-only change *plus* an `envs/**`
  change or it won't be detected.)
- **Local:** `cd <env> && terraform init && terraform apply` with `AWS_PROFILE=sauron-admin`.

---

## Step 0 — Enable NAT on the VPC

ECS tasks run in **private subnets with no public IP**, so without NAT they can't pull
the image from ECR, read the DB secret, or log to CloudWatch (tasks crash-loop).

1. In [`modules/solutions/vpc/main.tf`](modules/solutions/vpc/main.tf): **uncomment** the
   `nat_gateways` module block, and set the private route tables' `routes` to send
   `0.0.0.0/0` to the NAT (see the commented example in that file).
2. It's a `modules/**` change → add a trigger: touch a comment in
   `envs/vpc/DioProjects-us-east-1-sauron-vpc-DEV/terraform.tfvars`.
3. Commit + push to `main`, approve the apply. (~$32/mo while enabled.)

> Toggling NAT churns the public routes (the `route-tables` module keys routes by
> `count`). Harmless, but do it when nothing is serving.

## Wave 1 — `sauron-security-groups`

Creates ALB/ECS/RDS security groups + the tiered rules. Nothing to fill.

```bash
git add modules/solutions/security-groups envs/sauron-security-groups
git commit -m "feat: sauron security-groups (wave 1)" && git push origin main
# approve apply, then read outputs:
cd envs/sauron-security-groups/DioProjects-us-east-1-sauron-security-groups-DEV
terraform init && terraform output      # alb_sg_id, ecs_sg_id, rds_sg_id
```

## Wave 2 — `sauron-alb` + `sauron-rds`

Both depend only on the SGs. Paste the SG IDs first:
- `envs/sauron-alb/.../terraform.tfvars` → `alb_sg_id = "sg-..."`
- `envs/sauron-rds/.../terraform.tfvars` → `rds_sg_id = "sg-..."`

RDS uses **`manage_master_user_password = true`** — no password in tfvars/git; AWS
stores it in Secrets Manager.

```bash
git add modules/solutions/alb modules/solutions/rds envs/sauron-alb envs/sauron-rds
git commit -m "feat: sauron alb + rds (wave 2)" && git push origin main
# approve apply (RDS takes ~5-10 min), then read outputs:
( cd envs/sauron-alb/DioProjects-us-east-1-sauron-alb-DEV && terraform init && terraform output )   # target_group_arn, dns_name
( cd envs/sauron-rds/DioProjects-us-east-1-sauron-rds-DEV && terraform init && terraform output )   # address, master_user_secret_arn
```

## Wave 3 — `sauron-ecs-fargate`

Needs the SG + ALB + RDS values. Fill
`envs/sauron-ecs-fargate/.../terraform.tfvars`:
- `ecs_sg_id`        = wave-1 `ecs_sg_id`
- `target_group_arn` = wave-2 alb `target_group_arn`
- `DB_HOST` env var  = wave-2 rds `address`
- `DB_PASSWORD` secret `valueFrom` = `"<master_user_secret_arn>:password::"`
- `secret_arns`      = `["<master_user_secret_arn>"]`

```bash
git add modules/solutions/ecs-fargate envs/sauron-ecs-fargate
git commit -m "feat: sauron ecs-fargate (wave 3)" && git push origin main
# approve apply
```

## App image (go-app)

The task runs `298104300097.dkr.ecr.us-east-1.amazonaws.com/go-app-dev:latest`.
- **CI:** pushing to `go-app` `main` runs `docker-build-push.yml` → builds + pushes to ECR.
- **Local (amd64 — Fargate is x86_64):**
  ```bash
  aws ecr get-login-password | docker login --username AWS --password-stdin 298104300097.dkr.ecr.us-east-1.amazonaws.com
  docker buildx build --platform linux/amd64 -t 298104300097.dkr.ecr.us-east-1.amazonaws.com/go-app-dev:latest --push .
  ```
- **Roll a new image onto ECS** (CI doesn't do this automatically):
  ```bash
  aws ecs update-service --cluster sauron-DEV-cluster --service sauron-dev-service --force-new-deployment
  ```

## Verify

```bash
ALB=$(cd envs/sauron-alb/DioProjects-us-east-1-sauron-alb-DEV && terraform output -raw dns_name)
curl http://$ALB/health         # -> {"status":"healthy"}
aws ecs describe-services --cluster sauron-DEV-cluster --services sauron-dev-service \
  --query 'services[0].{running:runningCount,desired:desiredCount}'
aws logs tail /ecs/sauron-dev --since 5m     # "connected to database" / "migrations applied" / "server starting"
```

---

## Gotchas we hit (don't repeat them)

| Symptom | Cause | Fix |
|---|---|---|
| SG apply: `Character sets beyond ASCII are not supported` | em-dash `—` in `GroupDescription` | ASCII only in any AWS-bound `description`/`name`/`tags` |
| App crash-loop, targets unhealthy | tasks can't reach ECR/Secrets Manager | **enable NAT** (Step 0) — private subnets need egress |
| `pg_hba.conf ... no encryption (SQLSTATE 28000)` | RDS enforces SSL; app used `sslmode=disable` | go-app `db.go` + `migrate.go` → `sslmode=require` |
| migrate: `invalid port ":Uv" after host` | AWS password has special chars, broke the `postgres://` URL | build the URL with `net/url` (`url.UserPassword`) |
| `modules/**` change didn't deploy | CI detects `envs/**` only | touch a file in the env folder to trigger |
| plan: `ambiguous argument 'origin/main...HEAD'` | shallow checkout on PRs | fixed in `terraform-deploy.yml` (fetch-depth 0 + base SHA) |

## Cost & teardown

Running 24/7 ≈ **$65–75/mo** (NAT ~$32, ALB ~$16, RDS ~$13, Fargate ~$9). To go back
to ~$0 without losing the free scaffolding, destroy in **reverse** and disable NAT:

```bash
for e in sauron-ecs-fargate sauron-alb sauron-rds sauron-security-groups; do
  ( cd envs/$e/DioProjects-us-east-1-$e-DEV && terraform destroy -auto-approve )
done
# NAT: re-comment it in modules/solutions/vpc/main.tf, then re-apply the vpc env
( cd envs/vpc/DioProjects-us-east-1-sauron-vpc-DEV && terraform apply -auto-approve )
```

Keeps the VPC/subnets/IGW, state backend, ECR image, and IAM/OIDC roles (all free/pennies).
Note RDS is `skip_final_snapshot = true` → **no backup** is kept on destroy.

## Hardening before "real" use
- **HTTPS**: ACM cert + `:443` listener + 80→443 redirect (app is currently plain HTTP).
- Consider `internal = true` on the ALB, or restrict its SG ingress from `0.0.0.0/0`.
- `sslmode=verify-full` (bundle the RDS CA) instead of `require`.
