provider "aws" {
  access_key = "AKIA4DQMSMAZWV4U2IPL"
  secret_key = "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"
  region     = "ap-southeast-1"
}

resource "aws_instance" "jenkins" {
  ami           = "ami-00706790d2545217d"
  instance_type = "t2.micro"
  key_name = "peering"
  tags = {
    Name = "jenkins"
  }
}
