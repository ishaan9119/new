terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 4.19.0"
   }
 }
}
# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}
provider "aws" {
  region     = "ap-southeast-1"
  access_key = "AKIA4DQMSMAZ4Q6A33GV"
  secret_key = "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"
}
