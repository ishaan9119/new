resource "aws_vpc" "vpc1" {
           
         
		 cidr_block = "10.0.0.0/16"
		 
	tags =merge({Name="myvpc2"},var.common_tags)
	 
	 

}
