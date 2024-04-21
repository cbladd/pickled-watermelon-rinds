
# Pickled Watermelon Rinds

This repository contains Terraform configurations and a diagnostic shell script for setting up and maintaining a WordPress site hosted on AWS. The setup utilizes AWS services such as ECS (Elastic Container Service), RDS (Relational Database Service), and ELB (Elastic Load Balancing).  It's demo only, not for prod, unsecure, plain text creds, blah blah blah you get it.

## Repository Contents

- `main.tf` - Terraform configuration file for setting up the WordPress infrastructure on AWS.
- `debug.sh` - Shell script for checking the status and health of the deployed services.

## Prerequisites

Before you begin, ensure you have the following:
- AWS Account
- AWS CLI installed and configured
- Terraform installed
- `jq` installed (for parsing JSON in shell scripts)
- MySQL client installed (for database checks in the debug script)

## Setup Instructions

1. **Clone the Repository**
   ```
   git clone https://github.com/cbladd/pickled-watermelon-rinds.git
   cd pickled-watermelon-rinds
   ```

2. **Initialize Terraform**
   ```
   terraform init
   ```

3. **Apply Terraform Configuration**
   Make sure to review the changes Terraform will perform before applying. You can optionally plan and save the output:
   ```
   terraform plan -out=tfplan
   terraform apply "tfplan"
   ```

4. **Run the Debug Script**
   To check the status of the deployed infrastructure, use:
   ```
   chmod +x debug.sh
   ./debug.sh
   ```
