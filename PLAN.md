# Plan

## Goal
Build a complete AWS infrastructure portfolio using Terraform — starting from a remote state backend and growing into VPC, EC2, ECS, EKS, RDS, two-tier and three-tier applications, disaster recovery, and high availability.

---


## Immediate next steps

- [x] S3 + DynamoDB remote state backend deployed
- [x] GitHub Actions OIDC role deployed — keyless CI/CD auth
- [x] CI/CD workflows: plan on PR, plan + approval + apply on merge to main, manual destroy with approval
- [x] Build VPC module — networking foundation (subnets, route tables, NAT gateway, internet gateway)
- [x] Deploy VPC environment
- [x] Decide on compute: **ECS Fargate** chosen
- [x] Set up ECR — container registry for the go-app Docker image
- [x] Deploy ECS Fargate cluster + service to run the go-app
- [x] Deploy RDS PostgreSQL for the go-app database (AWS-managed password via Secrets Manager)
- [x] Wire go-app CI/CD: build Docker image → push to ECR (`go-app` `docker-build-push.yml`)
- [x] **Three-tier app deployed end-to-end and verified** (see `deploy-app-with-ecs.md` + JOURNAL 26–27/07)
- [x] Torn down to ~$0 after testing (NAT off, app stacks destroyed, VPC kept)

### Next up
- [ ] Harden the ALB: add HTTPS (ACM cert + :443 listener + 80→443 redirect); consider `internal = true`
- [ ] ECS deploy step in CI (build → push → `ecs update-service --force-new-deployment`) so image pushes auto-roll
- [ ] Refactor `route-tables` from `count` to `for_each` (avoids the public-route churn when toggling NAT)
- [ ] Continue the roadmap: EKS → EMR Serverless → DR/HA

---

## Infrastructure roadmap (in order)

| Step | What | Status |
|------|------|--------|
| 1 | S3 + DynamoDB remote state backend | ✅ done |
| 2 | VPC + subnets + route tables + NAT | ✅ done (NAT toggled off after testing) |
| 3 | Security groups | ✅ done |
| 4 | EC2 instance | ⏭️ skipped (went straight to containers) |
| 5 | Two-tier app (ALB + EC2) | ⏭️ skipped |
| 6 | ECS Fargate cluster + ECR | ✅ done |
| 7 | RDS (PostgreSQL) | ✅ done |
| 8 | Three-tier app (ALB + ECS + RDS) | ✅ done + verified live |
| 9 | EKS cluster | ☐ next |
| 10 | EMR Serverless | ☐ |
| 11 | Disaster recovery + high availability | ☐ |

---

## Workflow review checklist

Things to verify before the workflows are production-ready:

- [ ] `AWS_ROLE_TO_ASSUME` secret is set in GitHub repository settings
- [ ] `AWS_REGION` secret is set in GitHub repository settings
- [ ] The IAM role has the right permissions for Terraform to plan and apply
- [x] `terraform-deploy.yml` — changed-env detection fixed (fetch-depth 0 + diff vs event base SHA; the `origin/main...HEAD` form failed on PRs)
- [ ] `terraform-destroy.yml` — consider adding a manual confirmation step so destroy cannot be triggered accidentally
- [ ] Consider adding `terraform fmt` and `terraform validate` checks to `pr-validation.yml`

---

## Repositories

| Repo | Purpose |
|------|---------|
| `terraform-sauron` | All AWS infrastructure (this repo) |
| `go-app` | Go REST API + HTML frontend — will be deployed here via ECS |
