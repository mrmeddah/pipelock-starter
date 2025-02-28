# PipeLock-Starter

Welcome to **PipeLock-Starter**—the inaugural project under the PipeLock brand, launching a secure SaaS deployment pipeline. This repository hosts an Open SaaS application, developed with Wasp, deployed on AWS EC2, and automated with GitHub Actions. It’s tailored for startups needing fast, secure app launches—ideal for healthtech patient portals, micro-SaaS tools, or fintech dashboards.

## Overview
- **Project Goal:** Deliver a production-ready SaaS app with CI/CD and security in 3 weeks.  
- **Status:** Local setup complete, AWS EC2 deployment in progress.  
- **Target Audience:** New healthtech, micro-SaaS, and fintech ventures.

## Tech Stack
- **AWS EC2:** t2.micro instance (Ubuntu 22.04) for cloud hosting.  
- **GitHub Actions:** CI/CD automation for builds and deployments.  
- **Wasp:** Full-stack framework (React, Node.js, Prisma/Postgres).  
- **Nginx/Certbot:** TLS 1.3 encryption for HTTPS.  
- **IAM:** Role-based access control for security.  
- **WSL:** Development environment (Ubuntu on Windows).

## Getting Started
### Prerequisites
- Node.js (v18.19+ or v20+)
- npm (v9+)
- Docker Desktop
- Wasp CLI (v0.12+)
- AWS account (free tier)

### Installation
1. Clone the repo:  
   ```bash
   git clone https://github.com/mrmeddah/pipelock-starter.git
   cd pipelock-starter
1. Install Dependecies:
    ```bash
    npm install
2. Set up enviro:
    ```bash
    Copy .env.server.example to .env.server and configure (e.g., AWS SES keys later)
3. Start up the DB:
    ```bash
    wasp db start
4. DB Migration:
    ```bash
    wasp db migrate-dev
5. Run the APP:
    ```bash
    wasp start
## Deployment
###Local: 
Follow installation steps—test in WSL.
###AWS EC2:
- SSH into EC2: ```bash ssh -i your-key.pem ubuntu@[EC2-IP].
- Install Node.js/Docker:```bash  sudo apt install nodejs docker.io.
- Clone and run: Same steps as above, bind to 0.0.0.0:3000.
- Open port 3000 in Security Group.
- Live URL: http://[EC2-IP]:3000.

##Future Plans
###Project #2: HIPAA-Compliant Multi-Tenant SaaS - Adds user isolation and health data security (April 2025).
###Project #3: Multi-Region High Availability SaaS - Ensures uptime across AWS zones (May 2025).

##Contributing
- Open to feedback! File issues or PRs on GitHub.
- Suggestions for CI/CD, security, or scalability? Hit me up at: mrmeddah@yahoo.com!
