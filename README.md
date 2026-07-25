# IT Tools — Production Deployment on AWS

A production deployment of [it-tools](https://github.com/CorentinTh/it-tools) — a handy collection of developer utilities. containerised with Docker and deployed to AWS ECS Fargate using Terraform, with a fully automated CI/CD pipeline via GitHub Actions.

**Live at: https://it-tools.abdijalil.com**

---

## Overview

This project takes an existing open-source app and deploys it. The goal wasn't just to get it running, it was to do it right, with infrastructure as code, automated deployments, HTTPS, and a custom domain. The journey started with manually clickOps through the AWS Console to understand every service, then rebuilding everything as Terraform and automating it with GitHub Actions so a single `git push` handles the entire pipeline.

---

## Architecture

![Architecture Diagram](architecture_-_it-tools.png)


## Tech Stack

| Category | Tool |
|----------|------|
| App | it-tools (Vue / TypeScript) |
| Container | Docker, nginx:stable-alpine (multi-stage build) |
| Registry | AWS ECR |
| Infrastructure | Terraform (modular) |
| Compute | AWS ECS Fargate |
| Networking | VPC, ALB, NAT Gateway, 2 AZs |
| DNS | Cloudflare |
| HTTPS | AWS ACM (wildcard cert) |
| CI/CD | GitHub Actions + OIDC |
| State | Terraform remote state in S3 |

---

## Repo Structure

```
it-tools/
├── Dockerfile.mine              # Multi-stage Docker build
├── aws/                         # Terraform modules
│   ├── main.tf                  # Root module + OIDC/IAM
│   ├── variables.tf / outputs.tf / provider.tf
│   └── modules/
│       ├── vpc/                 # VPC, subnets, IGW, NAT Gateway
│       ├── alb/                 # ALB, listeners, target group, SG
│       ├── ecs/                 # Cluster, service, task def, IAM
│       ├── ecr/                 # Container registry
│       └── acm/                 # SSL certificate + validation
├── .github/workflows/
│   ├── docker-build.yml         # Build + push to ECR
│   └── terraform-deploy.yml     # Terraform apply + health check
├── architecture.png             # Architecture diagram
└── screenshots/                 # Screenshots
```

---

## How to Reproduce

**Prerequisites:** AWS CLI configured, Terraform, Docker, Node.js + pnpm, Cloudflare domain, GitHub repo with `AWS_ROLE_ARN` secret.

### 1. Run locally
```bash
pnpm install && pnpm dev
```

### 2. Build and test Docker image
```bash
docker build --platform linux/amd64 -f Dockerfile.mine -t it-tools:local .
docker run -p 80:80 it-tools:local
```

### 3. Set up OIDC (one time only)
```bash
cd aws && terraform init
terraform apply \
  -target=aws_iam_openid_connect_provider.github \
  -target=aws_iam_role.github_actions \
  -target=aws_iam_role_policy_attachment.github_actions_ecr \
  -target=aws_iam_role_policy_attachment.github_actions_admin \
  -var="container_image=placeholder"
```
Add the role ARN as `AWS_ROLE_ARN` in your GitHub repository secrets.

### 4. Deploy
```bash
git push origin main
```
GitHub Actions builds the image, pushes to ECR, and runs Terraform automatically.

### 5. Update Cloudflare DNS
```bash
terraform output alb_dns_name
```
Update your `it-tools` CNAME record in Cloudflare to the new ALB DNS name (DNS only, not proxied).

### 6. Verify
Visit `https://it-tools.abdijalil.com` — loads with padlock. `http://` redirects to `https://` automatically.

### Teardown
```bash
terraform destroy -var="container_image=<ecr-image-uri>"
```

---

## CI/CD Pipelines

**docker-build.yml** — triggers on push to `main` or manual dispatch. Authenticates to AWS via OIDC, builds with `--platform linux/amd64`, tags with commit SHA, pushes to ECR.

**terraform-deploy.yml** — triggers automatically after docker-build. Runs `terraform init → plan → apply`, waits 60s for ECS to start, then health checks the live URL. Fails the pipeline if the app is unhealthy.

---

## Challenges

**ARM vs AMD64** — images built on Apple Silicon are incompatible with ECS Fargate by default. Fixed with `--platform linux/amd64`.

**Terraform state in CI/CD** — GitHub Actions runners start fresh with no local state. Moving state to S3 solved this.

**OIDC setup** — trust policy conditions have to be exactly right (`repo:abdijalilimam/it-tools:*`). Small mistakes here cause silent auth failures.

**ACM validation** — domain was on Cloudflare so DNS validation CNAMEs had to be added manually. Used a wildcard cert (`*.abdijalil.com`) to cover all subdomains.

**Resource conflicts** — repeated terraform destroy/apply cycles caused "resource already exists" errors. Fixed with `terraform import`.

---

## Screenshots

See `screenshots/` for phase-by-phase documentation from local development to live production.