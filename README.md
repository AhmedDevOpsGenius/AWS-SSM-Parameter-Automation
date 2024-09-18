# AWS-SSM-Parameter-Automation
This repository automates fetching AWS SSM parameters using scripts (Bash/PowerShell), converts them into JSON, and uses Terraform to create or update parameters in AWS, streamlining parameter management.

**Table of Contents**
•	Overview
•	Features
•	Prerequisites
•	Directory Structure
•	Installation
•	Usage
•	Benefits
•	Contributing
•	License


**Overview**
This project aims to streamline the retrieval and management of AWS SSM parameters using the following tools:

Bash/PowerShell Scripts: Fetch SSM parameters from AWS and convert them into a JSON file.
Terraform: Use the JSON file to create or update SSM parameters in AWS.

**Features**
Fetch AWS SSM parameters using either Bash or PowerShell scripts.
Automatically convert the fetched parameters into JSON format.
Use Terraform to manage and apply these parameters back to AWS SSM, supporting automated infrastructure management.

**Prerequisites**
	Terraform installed on your local machine.
	AWS CLI configured with proper access rights to SSM parameters.
	Basic knowledge of AWS, SSM, and Terraform.

**Installation**
Clone the repository:
git clone https://github.com/yourusername/AWS-SSM-Parameter-Automation.git
cd AWS-SSM-Parameter-Automation

Install AWS CLI and configure your credentials:
aws configure
Ensure you have Terraform installed.

**Usage**
1. Fetching SSM Parameters
For Bash:
./scripts/fetch-ssm-params.sh

For PowerShell:
./scripts/fetch-ssm-params.ps1
These scripts will fetch the SSM parameters and save them in terraform/parameters.json.

2. Applying Terraform
After generating the parameters.json, navigate to the terraform/ directory and run Terraform:

cd terraform/
terraform init
terraform apply
Terraform will create or update the SSM parameters based on the JSON file.

**Benefits**
Automation: Simplifies the process of managing AWS SSM parameters by automating retrieval, conversion, and deployment.

Consistency: Ensures parameters are managed and updated consistently using infrastructure-as-code (IaC) principles.

Cross-Platform: Supports both Bash and PowerShell environments for flexibility in different systems.

**Contributing**
Feel free to open issues or submit pull requests if you'd like to improve the project.

**License**
This project is licensed under the MIT License. See the LICENSE file for details.
