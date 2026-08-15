# Journal

---

## 23/05/2026

### terraform-sauron

- Repo created modelled after a real company Terraform structure
- `modules/resources/` — atomic building blocks (s3-bucket, vpc, subnets, ec2, security-groups, route-tables, nat-gateways)
- `modules/solutions/` — higher-level stacks (tf-state-backend-s3, vpc, two-tier-app, three-tier-app)
- `envs/` — where Terraform is applied. Each solution has a `common/` folder + one folder per env instance
- `common/accounts/DioProjects/` — account-level tfvars
- `create_env.sh` — scaffolds new env folders with symlinks automatically
- 3 workflows: `pr-validation.yml`, `terraform-deploy.yml`, `terraform-destroy.yml`

### go-app

- Use case: Pharmaceutical — Medicine & Prescription System
- Architecture: monolith Go REST API + HTML frontend, ECS Fargate, RDS
- Repos: `terraform-sauron` (infra) and `go-app` (application)
- Go 1.26.3 installed, module initialised, folder structure created
- First file: `cmd/api/main.go` — HTTP server with `/health` endpoint
- `docker-compose.yml` — PostgreSQL 16 + pgAdmin, env vars from `.env` (gitignored)

---

## 07/06/2026

### AWS Account Setup

- Created AWS account, logged in as root
- Enabled MFA on root user (authenticator app, device named `iphone-root`)
- Root is only used for initial setup — never again after this

### IAM Identity Center (SSO)

- Enabled IAM Identity Center → Enable with AWS Organizations (free)
- Created `AdministratorAccess` permission set
- Created SSO user + `Admins` group, assigned group + permission set to `DioProjects` account
- Accepted email invite, set password + MFA on phone
- Login URL: `https://d-xxxxxxxxxx.awsapps.com/start` (bookmark this — never use console.aws.amazon.com directly)

```bash
aws configure sso
# session: sauron | start URL: <portal URL> | region: us-east-1 | profile: sauron-admin
aws sts get-caller-identity --profile sauron-admin   # confirmed DioProjects account
```

### S3 + DynamoDB State Backend

Bootstrapped with local state, then migrated to S3:

```bash
cd envs/tf-state-backend-s3/DioProjects-us-east-1-sauron-cicd-tfstate
export AWS_PROFILE=sauron-admin
terraform init && terraform apply        # creates bucket + DynamoDB
# updated state.tf to add S3 backend config
terraform init -migrate-state            # state moved to S3
```

Creates: `sauron-cicd-tfstate` S3 bucket (versioned, encrypted, TLS enforced) + DynamoDB table (state locking).

### GitHub Actions CI Role

```bash
cd envs/github-actions-ci-role/DioProjects-us-east-1-sauron-github-actions-ci-role
terraform init && terraform apply
```

Creates in IAM:
- OIDC provider — AWS trusts GitHub's identity system
- Role `github-actions-ci` — only `diomidispt/terraform-sauron` can assume it via OIDC
- Policy `github-actions-ci` — Terraform permissions for all planned infrastructure

No long-lived keys. GitHub gives each workflow run a short-lived JWT, AWS validates it, returns 1-hour credentials.

### GitHub Repo Config

- **Secret** `AWS_ROLE_TO_ASSUME` — ARN of `github-actions-ci` role
- **Variable** `AWS_REGION` — `us-east-1`

### CI/CD Behaviour

| Event | Result |
|---|---|
| Push to `main` | plan + apply on changed env folders |
| Pull request | plan only |
| Manual trigger | destroy on specified env path |

---

## 07/06/2026 (continued)

### CI/CD fixes and improvements

## 08/06/2026

### VPC — DEV environment

Deployed `envs/vpc/DioProjects-us-east-1-sauron-vpc-DEV` via CI/CD:

- **VPC** `sauron-DEV-VPC` — `10.0.0.0/20`
- **3 public subnets** (A/B/C) — `/24` each, for load balancers
- **3 private subnets** (A/B/C) — `/22` each, for EC2/ECS/RDS
- **Internet Gateway** — public internet access
- **6 route tables** — public routes → IGW, private routes → (NAT disabled)
- **NAT Gateway commented out** — re-enable in `modules/solutions/vpc/main.tf` when private subnets need internet (~$32/month)
- Updated `github-actions-ci` OIDC role to also trust `terraform-aws` repo

---

### CI/CD fixes and improvements

- Removed hardcoded `profile = "sauron-admin"` from all `state.tf` files — was breaking CI/CD since OIDC credentials don't use named profiles
- Fixed `sauron-data-dev` bucket name collision (S3 names are globally unique) — renamed to `sauron-data-dev-298104300097`
- Refactored deploy workflow: plan + apply split into two jobs, approval gate (`environment: apply`) required before apply runs
- PRs trigger plan only; merges to main trigger plan → approval → apply
- Destroy workflow also requires approval before running

---

## 09/06/2026

### ECR — go-app-dev

Created `envs/sauron-ecr/DioProjects-us-east-1-sauron-ecr-go-app-DEV/` using the existing ECR module:

- Repository name: `go-app-dev`
- Lifecycle policy: keep last 5 images (controls storage cost)
- IAM repo admin: `arn:aws:iam::298104300097:role/github-actions-ci`
- State backend: `sauron-cicd-tfstate` S3 bucket, symlinks pointing to `DioProjects` account

### GitHub Actions CI Role — go-app repo added

Updated `envs/github-actions-ci-role/DioProjects-us-east-1-sauron-github-actions-ci-role/terraform.tfvars`:

- Added `diomidispt/go-app:*` to `allowed_repos`
- The OIDC trust policy now allows both `diomidispt/terraform-aws` and `diomidispt/go-app` to assume the `github-actions-ci` role
- Required so the `go-app` CI/CD pipeline can authenticate to AWS and push images to ECR

---

## 26–27/07/2026

### Three-tier app deployed on ECS Fargate (go-app)

Deployed the full **internet → ALB → ECS Fargate → RDS** stack for the go-app pharma
system, in dependency-ordered "waves". Each stack feeds the next via manually-wired
tfvars (no `terraform_remote_state`); env-level `outputs.tf` (+ symlink) surface the
values for the next wave.

- **Wave 1 — `sauron-security-groups`** — new `modules/solutions/security-groups`
  (ALB/ECS/RDS SGs + tiered rules). VPC discovered by tag via `data` source.
- **Wave 2 — `sauron-alb` + `sauron-rds`** — ALB (LB + target group :8080 `/health`
  + HTTP :80 listener) and RDS PostgreSQL 16.4 `db.t3.micro`.
- **Wave 3 — `sauron-ecs-fargate`** — ECS cluster + Fargate service (from ECR
  `go-app-dev:latest`) attached to the ALB target group, in private subnets.
- **NAT gateway** enabled in `modules/solutions/vpc` (single-AZ) so private-subnet
  tasks can reach ECR / Secrets Manager / CloudWatch.

Patterns adopted (mirroring the `terraform` reference repo):
- ALB/RDS/ECS look up VPC + subnets by `tag:Name` data sources instead of passing raw IDs.
- **RDS AWS-managed master password**: `manage_master_user_password = true` → password
  generated + stored in Secrets Manager. No password in git/tfvars/TF_VAR. The secret
  ARN is an output; ECS injects `DB_PASSWORD` from it via the task's `secrets`.

### Bugs hit and fixed (the interesting part)

- **Non-ASCII in SG description** — em-dash (`—`) in `GroupDescription` → AWS
  `InvalidParameterValue: Character sets beyond ASCII are not supported`. Replaced with `-`.
- **RDS enforces SSL** — go-app connected with `sslmode=disable` → `pg_hba.conf ... no
  encryption (SQLSTATE 28000)`. Changed `db.go` + `migrate.go` to `sslmode=require`.
- **Password broke the migrate URL** — the AWS-generated password contained `:`, so
  `postgres://user:pass@host` mis-parsed (`invalid port`). Rebuilt the URL with
  `net/url` (`url.UserPassword`) so it's encoded. (`db.go` was fine — key=value DSN.)
- **CI changed-env detection** — `git diff origin/main...HEAD` failed on PRs (shallow
  checkout, unresolved ref) and `HEAD~1..HEAD` missed multi-commit pushes. Fixed:
  `fetch-depth: 0` + diff against the event base SHA.

App verified live: `GET /health → 200 {"status":"healthy"}` through the public ALB.

### Torn down to ~$0 (kept the free scaffolding)

To stop the ~$70/mo (NAT ~$32, ALB ~$16, RDS ~$13, Fargate ~$9): destroyed
`ecs-fargate`, `alb`, `rds`, `security-groups`, and **re-commented NAT + re-applied
`vpc`** (removed the NAT gateway/EIP but **kept the VPC/subnets/IGW**). Left intact
(free/pennies): VPC, S3 state backend, DynamoDB, ECR image, IAM/OIDC roles.

Added **`deploy-app-with-ecs.md`** — the wave-by-wave runbook to stand the app back up.

---

## 28/07/2026 – 15/08/2026

### KMS + SOPS secrets scaffolding — built, then torn down unused

Committed (`55b0db7`) alongside the not-yet-wired EKS module: `modules/resources/kms`
(customer-managed keys + aliases), `modules/resources/secrets` (Secrets Manager from a
list), `envs/sauron-kms` (applied — the SOPS key itself), `envs/sauron-secrets`
(SOPS-decrypted secrets, left at an empty baseline), and `.sops.yaml` wiring
`secrets(.enc).json` → the sauron-dev-sops-key ARN. Not an EKS dependency — general
reusable "git-committed encrypted secrets → Secrets Manager" plumbing, never populated.

**Found unexpectedly costing money (15/08):** `envs/sauron-kms`'s customer-managed
key (`sauron-dev-sops-key`) was live and protecting zero actual secrets —
`envs/sauron-secrets` was never populated past the empty baseline. Customer-managed
KMS keys bill a flat **$1/month** regardless of use (AWS-managed keys, e.g. the
default Secrets Manager/DynamoDB keys, are free — easy to conflate the two).
Confirmed via `terraform plan -destroy` in `envs/sauron-kms` that it matched the live
key exactly, then `terraform destroy`. Key went to `PendingDeletion`; shortened the
window from Terraform's default 30 days to AWS's minimum 7 days
(`aws kms cancel-key-deletion` + `aws kms schedule-key-deletion --pending-window-in-days 7`)
since the flat fee keeps prorating during the wait either way. Permanent deletion:
2026-08-22. To recreate later: `terraform init && plan && apply` in
`envs/sauron-kms/DioProjects-us-east-1-sauron-kms-DEV`.

Also confirmed while investigating: Identity Center has a second, unassigned
`KMS-Administrator` permission set (inline `kms:*` policy) sitting alongside
`AdministratorAccess` — redundant, since `AdministratorAccess` already grants full
KMS access. Left as-is (no cost, no risk).

### EKS — committed, still not deployed

Committed (`d4ad778`, 15/08) `envs/sauron-eks` (the DEV cluster stack) plus a small
`eks-cluster` module addition (`capacity_type` per node group, `ON_DEMAND`/`SPOT`).
Pushed straight to `main` intentionally, to see the real CI `plan` output — the
`apply` job needs a manual approval click (`environment: apply`, required reviewer
`diomidispt`) before `terraform apply` would ever run. Left unapproved on purpose:
plan-only run stays free; nothing gets created until the button is clicked.
Confirmed via `aws eks list-clusters` (empty) that it's genuinely not deployed.

### EKS — apply attempted, cluster came up, node group got stuck (no NAT) — destroy in progress

Approved the CI `apply` and ran it (15/08):

- **1st attempt failed fast**: `kubernetes_version = "1.31"` in
  `envs/sauron-eks/.../terraform.tfvars` fell out of AWS standard support on
  2025-11-26 (confirmed via `aws eks describe-cluster-versions`) — needs `EXTENDED`
  support type now, which the tfvars comment was explicitly trying to avoid. The
  `eks-secrets-key-DEV` KMS key + IAM roles/SG/launch template had already been
  created before the cluster resource failed — a partial apply, not a clean rollback.
  Bumped to `kubernetes_version = "1.36"` (current default, standard support until
  2027-08-02) and re-pushed (`8e424b2`).
- **2nd attempt: cluster came up** (`sauron-DEV-eks-cluster`, `ACTIVE`), but the
  managed **node group got stuck in `CREATING`** for 30+ min. Root cause: the ASG
  successfully launched an EC2 instance, but there's **no NAT Gateway in the VPC**
  (deliberately removed 27/07 after the ECS app teardown, see above) — and since
  `env_name != "prod"` the cluster only has a **public** API endpoint
  (`endpoint_private_access = false`). Nodes sit in **private** subnets, so with no
  NAT they have zero route to the internet — can't reach the public EKS API to
  register, can't pull CNI/kube-proxy images. The node boots but can never join;
  EKS just waits.
- Cancelled the hung GitHub Actions run (`gh run cancel`). This left a stale
  Terraform state lock in DynamoDB (`sauron-cicd-tfstate`, lock ID
  `537b6db6-a8a9-b7fd-13f6-68a964a98a7c`, held by the cancelled runner) —
  force-unlocked it (`terraform force-unlock`) so the stack isn't stuck.
- **As of writing, `envs/sauron-eks` is still live** (control plane, KMS key,
  IAM roles, SG, launch template, stuck node group) and needs a `terraform destroy`
  — queued to run via the `terraform-destroy.yml` workflow
  (`env_path=envs/sauron-eks/DioProjects-us-east-1-sauron-eks-DEV`) rather than
  locally, so it goes through the same approval gate as everything else.

**Takeaway:** this env can't actually reach `ACTIVE` node group without either (a) a
NAT Gateway (~$32/mo) so private-subnet nodes get outbound internet, or (b) flipping
`endpoint_private_access = true` *and* running nodes fully private with VPC
endpoints instead of NAT (more setup, no NAT bill). Needs a decision before the next
attempt — see PLAN.md.
