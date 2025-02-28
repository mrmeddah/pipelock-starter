# PipeLock-Starter

Welcome to **PipeLock-Starter**—the inaugural project under the PipeLock brand, launching a secure SaaS deployment pipeline. This repository hosts an Open SaaS application, developed with Wasp, deployed on AWS EC2, and automated with GitHub Actions. It’s tailored for startups needing fast, secure app launches—ideal for healthtech patient portals, micro-SaaS tools, or fintech dashboards.

## Overview
- **Project Goal:** Deliver a production-ready SaaS app with CI/CD and security in 3 weeks (Feb 23 - March 22, 2025).  
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

