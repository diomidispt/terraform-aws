# Scalable, DRY, and Modular Terraform Architecture for Multi-Environment Infrastructure

> A personal AWS infrastructure portfolio

---

## Overview

This repository implements a **scalable, modular, and DRY (Don't Repeat Yourself)** pattern
for managing infrastructure as code with Terraform. The structure is designed to support
**multiple environments, AWS accounts, and regions**, while minimizing code duplication and
maximizing reusability.

This pattern enables you to **scale from a single environment to many**, with minimal effort
and high maintainability.

---

## Definitions

### Resources

A resource is the **atom** of an IaC practice, it is a single piece of infrastructure.
For example an EC2 Instance.

### Solutions

A solution is the **molecule** of an IaC practice, it requires multiple resources to be
created. For example a VPC is made of Internet Gateways, Subnets etc.

### Environments

An environment is the **space where solutions exist**. The environment is the place where the
solution is actualised — meaning the place where the account and region is provided.

---

## Key Principles

- **DRY (Don't Repeat Yourself)** — common code and configuration are centralized and reused
  via symlinks and modules.
- **Separation of Concerns** — resources and solutions are clearly separated, making it easy
  to compose and extend infrastructure.
- **Scalability** — adding new environments, accounts, or regions is straightforward and does
  not require duplicating code.
- **Clarity** — the folder structure and naming conventions make it easy to understand what is
  deployed, where, and how.

---

## Folder Structure Explained

```
.
├── common/
│   └── accounts/
│       └── <account>/
│           ├── account.tfvars
│           └── region.<region>.tfvars
├── envs/
│   └── <solution>/
│       ├── common/
│       └── <account>-<region>-<solution>-<env>/
│           ├── common.account.auto.tfvars
│           ├── common.main.tf
│           ├── common.provider.tf
│           ├── common.region.auto.tfvars
│           ├── common.variables.tf
│           ├── state.tf
│           └── terraform.tfvars
├── modules/
│   ├── resources/
│   └── solutions/
└── create_env.sh
```

### 1. `common`

- Contains **reusable configuration for accounts and regions**.
- Each account has its own folder with `account.tfvars` and one or more
  `region.<region>.tfvars` files.
- These files are **symlinked** into environment folders to avoid duplication.

### 2. `envs`

- **This is where you run `terraform apply`.**
- Each solution (e.g., `sauron-rds`, `sauron-vpc`) has a `common` folder with shared code, and
  one or more environment folders named as `<account>-<region>-<solution>-<env>`.
- Environment folders are generated using `create_env.sh` and contain symlinks to common code
  and account/region variables, plus environment-specific files like `state.tf` and
  `terraform.tfvars`.

### 3. `modules`

- **`resources`** — contains atomic, reusable building blocks (e.g., `ec2-instance`, `kms`,
  `s3-bucket`). These are low-level modules that encapsulate a single resource or tightly
  related set of resources.
- **`solutions`** — contains higher-level, opinionated compositions of resources (e.g.,
  `bastion-host`, `rds-instance`). These modules combine multiple resources to deliver a
  complete solution.

### 4. `create_env.sh`

- An **interactive script** to generate new environment folders under `envs`, create the
  necessary symlinks, and scaffold required files.
- Ensures consistency and **reduces manual errors** when onboarding new environments.
- Handles backend configuration, symlinking, and initial formatting.

---

## The Pattern: DRY, Modular, and Scalable Terraform

This repository follows a pattern often referred to as the **"Environment-per-Folder"** or
**"Environment-per-Workspace"** pattern, enhanced with **symlinks** and **strict module
layering**.

### Key Features

- **No Code Duplication** — common code and variables are symlinked, not copied, into each
  environment.
- **Easy Environment Creation** — new environments are created by running a script, not by
  copying and pasting code.
- **Clear Module Boundaries** — resource modules are for atomic building blocks; solution
  modules are for composed, deployable stacks.
- **Per-Environment State** — each environment folder has its own backend configuration and
  state file, supporting isolated deployments.

---

## How to Use This Pattern

### Creating a New Environment

**1. Run `create_env.sh`** and follow the prompts to select:

- Environment (solution)
- Account
- Region
- Unique identifier (optional)
- Stage (`DEV`, `STAG`, `PROD`)

The script will create a new folder under `envs/<solution>/` with the appropriate name and
symlinks.

**2. Add or edit `terraform.tfvars`** in the new folder for environment-specific variables.

**3. Authenticate with AWS:**

```bash
aws sso login <your_profile>
export AWS_PROFILE=<your_profile>
```

**4. Run Terraform commands** (`init`, `plan`, `apply`) inside this new folder.

### When to use resources vs. solutions

- **`resources`** — use for low-level, reusable components (e.g., a single EC2 instance, a KMS
  key, a VPC). These should be generic and composable.
- **`solutions`** — use for higher-level, opinionated stacks that solve a business problem
  (e.g., a bastion host setup, a subnet router, a full RDS instance with monitoring and
  security). These modules can use multiple resource modules internally.

---

## Symlinks: How and Why

Each environment folder contains symlinks to:

- `common.main.tf`, `common.provider.tf`, `common.variables.tf` — from the
  `envs/{solution}` common folder.
- `common.account.auto.tfvars` and `common.region.auto.tfvars` — from the appropriate account
  and region in `accounts`.

This ensures that **all environments use the same code and configuration**, reducing drift and
maintenance overhead.

---

## Benefits

- **Scalability** — add new environments, accounts, or regions with a single script.
- **Maintainability** — update shared code in one place; all environments benefit.
- **Clarity** — easy to see what is deployed where, and to onboard new engineers.
- **Flexibility** — mix and match modules to compose new solutions as requirements evolve.

---

## Technical Tips for DevOps Engineers

- **State Management** — each environment folder has its own `state.tf` backend config, so
  state is isolated per environment. This is critical for safe, parallel deployments.
- **Symlink Safety** — if you move or rename files in `common` or `accounts/`, update or
  recreate symlinks in environment folders.
- **Automation** — use `create_env.sh` for even faster environment provisioning.
- **Secrets Management** — use SOPS and KMS for secrets, as described in the repo README.
  Never store unencrypted secrets in version control.

---

## Summary

This pattern is ideal for **organizations managing infrastructure across multiple
environments, accounts, and regions**. By leveraging symlinks, strict module layering, and
per-environment workspaces, you can scale your infrastructure codebase efficiently and
maintain a high level of quality and consistency.

---

## The workload this repository delivers

The workload it currently delivers is a **three-tier web application** — a Go REST API
(`go-app`) running on **ECS Fargate**, fronted by an **Application Load Balancer**, backed
by **RDS PostgreSQL**, all inside a VPC built from scratch, deployed by **GitHub Actions
with OIDC** (no long-lived AWS keys).

```
                    Internet
                       │
                       │ :80
              ┌────────▼─────────┐
   Web tier   │       ALB        │   public subnets  (2 AZs)
              └────────┬─────────┘
                       │ :8080
              ┌────────▼─────────┐
   App tier   │  ECS Fargate     │   private subnets (2 AZs)
              │  go-app (Go API) │   no public IP
              └────┬────────┬────┘
                   │ :5432  │ :443
              ┌────▼─────┐  └──────► NAT ──► ECR · Secrets Manager · CloudWatch Logs
   Data tier  │   RDS    │              (image pull, DB password, logs)
              │ Postgres │           private subnets
              └──────────┘
```

Account `298104300097` · region `us-east-1` · VPC `sauron-DEV-VPC`.

---

## Modules

### `modules/resources/` — atomic building blocks

| Module | Builds |
|--------|--------|
| `vpc` | VPC + internet gateway + DNS settings |
| `subnets` | Subnets from a map (CIDR + AZ) |
| `route-tables` | Route tables, routes, and subnet associations |
| `nat-gateways` | NAT gateways + their EIPs |
| `security-groups` | Generic security group + rules |
| `s3-bucket` | S3 bucket + versioning + public-access block + bucket policy |
| `ecr` | ECR repository + lifecycle policy + repo policy |
| `kms` | KMS keys + aliases |
| `secrets` | Secrets Manager secrets |
| `budget` | AWS Budgets + notifications |

### `modules/solutions/` — composed, deployable stacks

| Module | Builds |
|--------|--------|
| `vpc` | Full network: VPC + public/private subnets across every AZ + route tables + optional NAT |
| `security-groups` | The three-tier rule set: ALB ← internet, ECS ← ALB, RDS ← ECS, and nothing else |
| `alb` | Public ALB + target group (`ip` targets) + HTTP listener + health check |
| `ecs-fargate` | ECS cluster + task definition + service + execution/task IAM roles + CloudWatch log group |
| `rds` | DB subnet group + private RDS instance with an AWS-managed master password in Secrets Manager |
| `eks-cluster` | EKS control plane + managed node group + access entries |
| `tf-state-backend-s3` | S3 bucket + DynamoDB lock table for remote state (wraps `cloudposse/tfstate-backend/aws`) |
| `github-actions-ci-role` | GitHub OIDC provider + CI role scoped to specific repos (wraps `terraform-aws-modules` IAM) |

The rule of thumb: **if you would ever want it on its own, it is a resource; if it only
makes sense as a set, it is a solution.**

---
### Security posture

- The ALB is the **only** thing with an internet-facing rule (`:80` from `0.0.0.0/0`).
- ECS tasks run in **private subnets with no public IP** and accept traffic **only from the
  ALB's security group** — not from a CIDR, from the security group itself.
- RDS accepts `:5432` **only from the ECS security group**, and is not publicly accessible.
- The database password is **never in Terraform code or state as plaintext** —
  `manage_master_user_password = true` puts it in Secrets Manager, and ECS injects it into
  the container as `DB_PASSWORD` via the task definition's `secrets` block. The execution
  role is granted `secretsmanager:GetSecretValue` on that one ARN only.
- CI authenticates through **GitHub OIDC** — there are no AWS access keys in GitHub.

---

## CI/CD

Workflows in [.github/workflows/](.github/workflows/):

| Workflow | Trigger | Behaviour |
|----------|---------|-----------|
| `pr-validation.yml` | PR opened / edited | Validates the PR title format |
| `terraform-deploy.yml` | PR → `plan`; push to `main` → `plan` + **manual approval** + `apply` | Only the environments touched by the diff |
| `terraform-destroy.yml` | Manual `workflow_dispatch` with an `env_path` | Destroys one environment, behind the same approval gate |

The pipeline **detects changed environments from the git diff** (`envs/**`, excluding
`common/`) and plans only those. This is what makes the pattern scale in CI: fifty
environments in the repository, but a pull request that touches one plans exactly one.

> Because detection is scoped to `envs/**`, a change to `modules/**` alone will not trigger
> anything — touch the consuming environment's `terraform.tfvars` to deploy it.

`apply` runs in the GitHub `apply` environment, which pauses for manual approval before any
change reaches AWS.

---

## Working with the repository

### Create a new environment

```bash
./create_env.sh
```

Prompts for solution → account → region → optional unique id → stage, then creates
`envs/<solution>/<account>-<region>-<solution>-[<id>-]<stage>/` with every symlink, a
`state.tf` pointing at a unique key in the state bucket, and an empty `terraform.tfvars`.

Fill in `terraform.tfvars` and that is the entire diff for a new environment.

### Deploy

```bash
aws sso login --profile sauron-admin
export AWS_PROFILE=sauron-admin AWS_REGION=us-east-1

cd envs/<solution>/<env-folder>
terraform init
terraform plan
terraform apply
```

Account and region variables load automatically — they are `*.auto.tfvars` symlinks. The
provider pins `allowed_account_ids`, so an apply pointed at the wrong account fails fast
instead of building something in the wrong place.

### Bootstrap a fresh account

1. Set the account ID in `common/accounts/<account>/account.tfvars`.
2. Apply `envs/tf-state-backend-s3/<env>` with **local** state, then
   `terraform init -migrate-state` to move it into the bucket it just created.
3. Apply `envs/github-actions-ci-role/<env>` and set `AWS_ROLE_TO_ASSUME` in GitHub.
4. Everything after that is normal CI flow.

### Secrets (SOPS + KMS)

Secrets are committed **encrypted**, with [SOPS](https://github.com/getsops/sops) and a KMS
key (`.sops.yaml`). Encrypt with `sops --encrypt --in-place secrets.json`; Terraform reads
them through the `sops_file` data source. Nothing unencrypted goes into version control.

---

## Cost posture

This is a personal lab, so the expensive pieces are **switchable**:

- The **NAT gateway** (~$32/month) is commented out in
  [modules/solutions/vpc/main.tf](modules/solutions/vpc/main.tf) and turned on only while
  the app stacks are running — ECS in private subnets needs it to pull from ECR, read the
  DB secret, and ship logs.
- The app stacks (`alb`, `ecs-fargate`, `rds`) are destroyed after a demo; the VPC and the
  state backend are kept, since they cost nothing idle.
- `sauron-budget` emails on the first dollar over the monthly limit.

Turning the whole three-tier app on or off is running the runbook forward or backward — the
code is unchanged either way. That reversibility *is* the point of the pattern.

---

## Related repositories

| Repo | Purpose |
|------|---------|
| `terraform-aws` | All AWS infrastructure (this repo) |
| `go-app` | The Go REST API deployed here — pharmaceutical management system (medicines, patients, prescriptions), PostgreSQL, `/health` endpoint used by the ALB target group, Docker image built and pushed to ECR by its own workflow |

## Further reading in this repo

- [deploy-app-with-ecs.md](deploy-app-with-ecs.md) — step-by-step runbook for the three-tier stack
- [PLAN.md](PLAN.md) — roadmap and current status
- [JOURNAL.md](JOURNAL.md) — build log, including what broke and why
