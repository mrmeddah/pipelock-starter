# Pipelock Starter - Secure BI on AWS

Fast, secure business intelligence for small businesses.


![Getting Started](/docs/images/image.png)


## What It Does
- **Real-Time Dashboards**: Metabase on AWS ECS Fargate; see sales, customers, or analytics instantly.
- **Secure & Scalable**: Private subnets, encrypted RDS, locked-down IAM your data’s safe, grows with you.
- **Affordable**: Approx ~50-70$/month to run, beats 15$K+ tools like Tableau. Customizable depending on the needs, can reach '200$' per month cloud-costs, but in terms of users, it's unlimited unlike other paid tools

**Live Demo**: ['Probably down' - https://metabase.pipelock.dev ]  
**Built For**: E-commerce, agencies, SaaS startups, health-tech (basically any business that uses data to make decisions).

## Tech Stack
- **AWS**: ECS Fargate (app), RDS PostgreSQL (DB), ALB (access), S3 (storage).
- **Terraform**: Modular infra; VPC, ECS, RDS, IAM, and ALB in reusable folders.
- **Docker**: Lightweight Metabase container. (Basic Dockerfile with healthcheck)
- **Github Actions**: CI/CD via GitHub Actions (Soon).

## How It Works
1. **Deploy**: `terraform apply` in `infra/terraform/enviroments/dev/`; then it is live.
2. **Connect**: Plug in your data (Shopify, Google Analytics, etc.).
3. **Run**: Dashboards up, secure, no maintenance.

## Setup (For Devs)
```bash
# Clone repo
git clone https://github.com/mrmeddah/pipelock-starter.git
cd pipelock-starter/infra/terraform/enviroments/dev/

# Configure AWS CLI & Terraform
aws configure # To authenticate with your AWS credentials
terraform init
terraform validate # (In case you made any changes and wanna check if they are are valid)
terraform plan -out=tfplan # This will help you understand the dependencies and work around them
terraform apply # This will create the resources defined and deploy metabase directly to your ECR
```

## Cost Saving Tips
- Use `single_nat_gateway = true` in dev
- Set `desired_count = 0` when not testing
- Enable ECS Spot instances
- NAT Gateway costs $0.045/hr (≈$32/month if running 24/7)
- ALB costs $0.025/hr (≈$18/month)
- **Always run `terraform destroy` after testing "it will delete what's created"**

## Break-Glass Procedure
To nuke all resources immediately:
```bash
terraform destroy -auto-approve
```

## First-Time Setup
1. Create S3 bucket for Terraform state:
   ```bash
   aws s3api create-bucket --bucket your-tf-state-$(aws sts get-caller-identity --query Account --output text)


## Contact: 

**X**: DM me on X @medsupernova.

  
**E-mail**: Email me at mrmeddah@yahoo.com 

# This is a comprehensive README file dedicated to the Terraform Repo
## Structure of Terraform Repo via the tree command:

```bash
.
├── README.md
├── budget.json 
├── environments
│   ├── dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── terraform.tfvars
│   │   ├── tfplan
│   │   └── variables.tf
│   └── prod
│       ├── backend.tf
│       ├── main.tf
│       ├── providers.tf
│       ├── terraform.tfvars
│       └── variables.tf
└── modules
    ├── alb
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── ecs
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── iam
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── rds
    │   ├── README.md
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── vpc
        ├── main.tf
        ├── outputs.tf
        └── variables.tf

```

10 directories, 30 files

## Explaining the Terraform Structure

### I organized these Terraform files as re-usable files. By adding variables to ensure the customization later and avoid hardcoding, separating each module in a dedicated folder to ensure encapsulation of the logical components, and to avoid a monolithic structure. Outputs are used to expose key attributes to each module.

Key Highlights from the dev Plan

VPC		CIDR 10.0.0.0/16 with AZ redundancy
RDS		PostgreSQL 12.20 on t4g.micro (dev-optimized)
ECS		Fargate Spot with 1vCPU/2GB RAM
ALB		HTTPS redirect working with an existing ACM cert

Security  Least-privilege IAM + locked-down security groups + WAF for SQLi and XSS (Cross Site Scripting) +         AWS Secrets Manager


## The Architectures

### GitHub Actions simple CI/CD

```mermaid
graph LR
A[Code Push] --> B[Build Docker Image]
B --> C[Push to ECR]
C --> D[Terraform Plan]
D --> E[Manual Approval]
E --> F[Terraform Apply]
```

## When CI/CD Runs
1. **On PR to Main**:
   - `terraform plan` (dry-run)
   - Docker image build test
2. **Merge to Main**:
   - Auto-deploy to dev
   - Requires manual approval for prod
3. **Scheduled (2AM UTC)**:
   - Destroy dev resources
   - Recreate fresh environment


## Security Best Practices
- [ ] Enable VPC Flow Logs
- [ ] Restrict ALB SG to known IPs
- [ ] Enable RDS encryption
- [ ] Rotate Secrets Manager values monthly

### Architecture Diagram behind the inter-connection of these modules.
```mermaid
sequenceDiagram
    participant ECS
    participant SM as Secrets Manager
    participant RDS
    participant ALB

    ECS->>SM: Get DB credentials (at startup)
    SM-->>ECS: Returns username/password
    ECS->>RDS: Connect via psql (host:5432)
    ALB->>ECS: Route HTTPS traffic to :3000
```



### Authentication Architecture Diagram:
```mermaid
sequenceDiagram
    participant ECS
    participant SM as Secrets Manager
    participant RDS
    ECS->>SM: GetSecretValue (DB credentials)
    SM-->>ECS: {username: "metabase_admin", password: "*****"}
    ECS->>RDS: Connect (psql://host:5432)
    RDS-->>ECS: Authentication OK
```



### Architecture Diagram of the request flows:
```mermaid
flowchart LR
    User-->|HTTPS:443|ALB
    ALB-->|HTTP:3000|ECS
    ECS-->|Private Subnet|RDS
    ECS-->|VPC Endpoint|S3[(S3)]
```

```mermaid
flowchart TB
    subgraph AWS
        subgraph VPC
            ALB -->|:3000| ECS
            ECS --> RDS
            ECS --> S3[(S3 VPC Endpoint)]
        end
        SM[(Secrets Manager)]
    end
    User -->|HTTPS:443| ALB
    ECS -->|Get DB creds| SM
```


### IAM Roles Breakdown
| Role | Purpose | Critical Permissions |
|------|---------|----------------------|
| `ecsTaskExecutionRole` | Pull images + read secrets | `ecr:GetAuthorizationToken`, `secretsmanager:GetSecretValue` | 
| `ecsTaskRole` | Metabase app permissions | `rds-db:connect`, `s3:PutObject` |
| `ciCdRole` | GitHub Actions deploy | `ecs:UpdateService`, `ecr:BatchGetImage` |