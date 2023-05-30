terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 4.19.0"
   }
 }
}
provider "aws" {
  region                  = "ap-southeast-1"
  profile                 = "ishaan"
}
