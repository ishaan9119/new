terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 4.19.0"
   }
 }
}
provider "aws" {
  region                    = "ap-southeast-1"
  shared_credentials_files  = ["%USERPROFILE%/.aws/credentials"]
  profile                   = "customprofile"
}
