resource "aws_instance" "my_vm" {
 ami                       = "ami-00706790d2545217d" //Ubuntu AMI
 instance_type             = "t2.micro"

 tags = {
   Name = "My EC2 instance",
 }
}
