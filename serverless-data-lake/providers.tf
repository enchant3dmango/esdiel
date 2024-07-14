# Configure the AWS Provider
provider "aws" {
  shared_credentials_files = "$HOME/.aws/credentials"
  region                   = var.aws_region
}
