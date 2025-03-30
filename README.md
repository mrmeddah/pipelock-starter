# Pipelock Starter - Secure BI on AWS

Fast, secure business intelligence for small businesses.


![Getting Started](/docs/images/image.png)


## What It Does
- **Real-Time Dashboards**: Metabase on AWS ECS Fargate; see sales, customers, or analytics instantly.
- **Secure & Scalable**: Private subnets, encrypted RDS, locked-down IAM your data’s safe, grows with you.
- **Affordable**: Approx ~$20/month to run, beats $15K+ tools like Tableau.

**Live Demo**: [Coming Soon - https://metabase.pipelock.dev ]  
**Built For**: E-commerce, agencies, SaaS startups, health-tech (basically any business that uses data to make decisions).

## Tech Stack
- **AWS**: ECS Fargate (app), RDS PostgreSQL (DB), ALB (access), S3 (storage).
- **Terraform**: Modular infra; VPC, ECS, RDS, IAM, and ALB in reusable folders.
- **Docker**: Lightweight Metabase container. (Basic Dockerfile with healthcheck)
- **Github Actions**: CI/CD via GitHub Actions (Soon).

## How It Works
1. **Deploy**: `terraform apply` in `infra/dev/`; then it is live.
2. **Connect**: Plug in your data (Shopify, Google Analytics, etc.).
3. **Run**: Dashboards up, secure, no maintenance.

## Setup (For Devs)
```bash
# Clone repo
git clone https://github.com/mrmeddah/pipelock-starter.git
cd pipelock-starter/infra/dev/

# Configure AWS CLI & Terraform
aws configure
terraform init
terraform apply
```
## Contact: 

**X**: DM me on X [@medsupernova]
**E-mail**: Email me at [mrmeddah@yahoo.com].

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
10 directories, 30 files

```

## Explaining the Terraform Structure

### I organized these Terraform files as re-usable files. By adding variables to ensure the customization later and avoid hardcoding, separating each module in a dedicated folder to ensure encapsulation of the logical components, and to avoid a monolithic structure. Outputs are used to expose key attribute to each module.

## The Architectures


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