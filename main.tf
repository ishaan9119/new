resource "aws_instance" "my_vm" {
 ami                       = "ami-065deacbcaac64cf2" //Ubuntu AMI
 instance_type             = "t2.micro"

 tags = {
   Name = "My EC2 instance",
 }
}
resource "aws_instance" "windows" {
  ami                         = data.aws_ami.Windows_2019.image_id
  instance_type               = var.windows_instance_types
  key_name                    = aws_key_pair.my_key_pair.key_name
