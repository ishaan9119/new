resource "aws_instance" "my_vm" {
 ami                       = "ami-065deacbcaac64cf2" //Ubuntu AMI
 instance_type             = "t2.micro"

 tags = {
   Name = "My EC2 instance",
 }
}
