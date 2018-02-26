# Terraform Settings
# # https://www.terraform.io/docs/configuration/terraform.html
terraform {
  required_version = ">= 0.11.3"
}

# Provider
# # https://www.terraform.io/docs/providers/aws/index.html
provider "aws" {
  alias   = "tokyo"
  region  = "ap-northeast-1"
  profile = "sample-profile"
}

provider "aws" {
  alias   = "oregon"
  region  = "us-west-2"
  profile = "sample-profile"
}

# Variables
# # https://www.terraform.io/docs/configuration/variables.html

variable "ProjectName" {
  type    = "string"
  default = "ses-test"

  # only lowercase alphanumeric characters and hyphens allowed
}
