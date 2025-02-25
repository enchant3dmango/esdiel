# Serverless Data Lake (Esdiel) using Amazon Web Service

### Setup
#### Prerequisites
- Terraform (1.10.5)
- AWS CLI (2.17.32)
- Python (3.11)
- GNU Make (3.81)

#### Steps
- Make sure to clone the repository first to your local repository!
- Also make sure you already have AWS secret key and access key on your local directory.
- Create a profile in your AWS config and credentials file then adjust the variable **aws_profile** in **variables.tf**.
- Adjust all variables in **variables.tf** if needed.

##### Makefile
1. Navigate to **serverless-data-lake** directory.
2. Run `make install` to install dependencies.
3. Run `make format` to format all Python code in serverless-data-lake directory.
4. Run `make lint` to lint all Python code in serverless-data-lake directory.

##### Terraform
1. Ensure you already have configured AWS credentials in your device.
2. Navigate to **serverless-data-lake** directory, then navigate to **terraform** directory.
3. Create a `.tfvars` file in the terraform directory using the `.tfvars.template`. Then replace all placeholder with your own variable values.
4. Run `terraform init` to initialize all terraform resources.
5. Run `terraform plan -var-file=.tfvars -out=plan.tfplan` to create execution plan.
6. Run `terraform apply "plan.tfplan"` to apply the execution plan.
7. Run `terraform show` to inspect the current state.

##### Extra Steps
1. Upload data.csv to the data folder in the source bucket using AWS CLI or AWS Console.
2. Check your AWS Glue ETL Job and your AWS Glue Data Catalog.

Ah, there you go!

### References
- [AWS Documentation](https://docs.aws.amazon.com/)
- [Terraform Registry](https://registry.terraform.io/)
- [Spacelift](https://docs.spacelift.io/vendors/terraform)
