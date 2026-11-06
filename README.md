# SafeMerge

Security from pull request to production. CS6620 Fundamentals of Cloud Computing, Northeastern University.

- **Stage 1 (SAST):** every pull request is scanned with the course-provided SAST scanner. Results are posted as PR comments and the `safemerge/sast` commit status. Branch protection blocks merges on HIGH findings.
- **Stage 2 (deploy gate):** every merge is deployed to a temporary staging task on ECS Fargate and tested with the course-provided pentest tool. The result is posted as `safemerge/deploy-gate`, and the production deploy job runs only on success.

Design decisions and shared interfaces are in [docs/DESIGN.md](docs/DESIGN.md).

## Team
| Area | Steward |
|---|---|
| SAST pipeline | Shahana Yasmeen Shaik |
| Deploy gate | Aniket Nandi |
| Platform and dashboard (production account owner) | Srujan Vooturi |

Stories rotate, so anyone can work in any folder. The area steward reviews.

## Repo layout
```
terraform/     AWS infrastructure (bootstrap, envs, modules)
services/      Lambda functions: webhook, sast-worker, dashboard-api, notifier
scanners/      Course-provided SAST and pentest tools, plus Dockerfiles
dashboard/     Frontend, served through API Gateway
docs/          Design notes and interfaces
```

## Rules
- Never commit secrets, `*.tfstate`, or `.terraform/`.
- Test in your own Learner Lab account before opening a pull request.
- Every change goes through a pull request reviewed by the area steward.
- Terraform never creates IAM roles. Everything uses LabRole.
- Only Srujan applies Terraform to production.
