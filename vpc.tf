

resource "aws_vpc" "vpc1" {
           
         
		 cidr_block = "10.0.0.0/16"
		 
	tags =merge({Name="myvpc2"},var.common_tags)
	 
	 

}
/*
resource "aws_vpc" "vpc1" {
           provider = aws.mumbai 
         
		 cidr_block = "10.0.0.0/24"
		 
	tags =merge({Name="myvpc1"},var.common_tags)
	 
	 
}

resource "aws_vpc_peering_connection" "peering" {
  
  peer_vpc_id   = aws_vpc.vpc1.id
  vpc_id        = aws_vpc.vpc2.id
  
  peer_region   = "ap-south-1"

  tags = {
    Name = "VPC Peering1"
  }
}

*/




resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description      = "allow ssh traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
	cidr_blocks      =["0.0.0.0/0"]
	}
	ingress {
	description   ="tcpport"
	from_port        =80
	to_port          =80
	protocol         ="tcp"
	cidr_blocks       =["0.0.0.0/0"]
	
    
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "sg1"
  }


}

resource "aws_key_pair" "key" {
  key_name   = "manoj"
  public_key = file("./manoj.pub")
}

resource "aws_instance""ec2"{
          ami =var.ami
		  count =3
		  instance_type=var.instance_type

		  key_name= aws_key_pair.key.key_name

		  subnet_id =aws_subnet.psbnt.*.id[count.index]

		

		  vpc_security_group_ids=[aws_security_group.sg1.id]
		  
	tags={
	      Name ="publc server-${count.index}"
		}
	
		
}



 resource "aws_subnet""psbnt" {

        count=length(var.availability_zone)

		vpc_id = aws_vpc.vpc1.id

		map_public_ip_on_launch ="true"

		availability_zone=element(var.availability_zone,count.index)

		cidr_block=element(var.cidr,count.index)

      tags = merge({Name="psbnt-${count.index}"},var.common_tags)

}
/*

 resource "aws_subnet""prvtt" {
        count=length(var.availability_zone)

		availability_zone=element(var.availability_zone, count.index )

		vpc_id = aws_vpc.vpc1.id
		
		cidr_block=element(var.prvt-cidr,count.index)

     tags = merge({Name="prvtsbnt-${count.index}"},var.common_tags)
}
*/
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc1.id

  tags = merge({Name ="igw"},var.common_tags)
   
  }
  

resource "aws_route_table" "rtble" {
  vpc_id = aws_vpc.vpc1.id
   
   
   tags={
        Name ="pblcrtble"
	}
   
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
}
/*
resource "aws_eip" "ellip" {

}
resource "aws_nat_gateway" "nat"{

          allocation_id =aws_eip.ellip.id
		  
          subnet_id     =aws_subnet.psbnt.*.id[1]
    tags ={ 
	      Name ="natgate1"
		}
}

resource "aws_route_table" "prvtrtble" {
             vpc_id = aws_vpc.vpc1.id
        route {
		    cidr_block ="0.0.0.0/0"
			nat_gateway_id =aws_nat_gateway.nat.id
		}
   
   tags={
        Name ="prvtrtble"
	}
}
*/
resource "aws_route_table_association" "rtassot" {
    count =3
  subnet_id      = aws_subnet.psbnt.*.id[count.index]
  route_table_id = aws_route_table.rtble.id

}
/*
resource "aws_route_table_association" "pvtasso" {
    count =3
  subnet_id      = aws_subnet.prvtt.*.id[count.index]
  route_table_id = aws_route_table.prvtrtble.id

}



#launch configuration and auto scalinggroups


resource "aws_launch_configuration" "lc1" {
  name_prefix   = "terraform-lc-example-"
  image_id      = var.ami
  instance_type = var.instance_type
security_groups =[aws_security_group.sg1.id]
key_name =aws_key_pair.key.key_name
 
  user_data =file("./userdata.txt")
   tags = {
         Name ="asg-servers"
	}
  lifecycle {
    create_before_destroy = true
  }
}



  resource "aws_autoscaling_group" "asg" {
  name                      = "foobar3-terraform-test"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
   vpc_zone_identifier       = aws_subnet.prvtt.*.id
  desired_capacity          = 3
  force_delete              = true

  launch_configuration      = aws_launch_configuration.lc1.name
  
  
}



resource "aws_lb" "apload" {
  name               = "apload"
  load_balancer_type = "application"
security_groups     =[aws_security_group.sg1.id]
  
    subnets        = aws_subnet.psbnt.*.id
    
  }
  
    # target group creation
   
 resource "aws_alb_target_group" "target-group-1" {
   count =2
  name = "target-group-${count.index+1}"
  vpc_id = aws_vpc.vpc1.id
  port = 80
  protocol = "HTTP"

  lifecycle { create_before_destroy=true }

  health_check {
    path = "/"
    port = 80
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"  # has to be HTTP 200 or fails
  }
}

resource "aws_lb_target_group_attachment" "test" {
       count = 3
  target_group_arn = aws_alb_target_group.target-group-1[0].arn
  target_id        = aws_instance.ec2[count.index].id
  
}


resource "aws_autoscaling_attachment" "asg_attachment_trgt" {
      count =3
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_alb_target_group.target-group-1[1].arn
}

resource "aws_lb_listener" "front_end" {
    
  load_balancer_arn = aws_lb.apload.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target-group-1[0].arn
  }
}
resource "aws_lb_listener" "front_end1" {
    
  load_balancer_arn = aws_lb.apload.arn
  port              = "79"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target-group-1[1].arn
  }
}


resource "null_resource" "null11"{
       provisioner "local-exec" {
	      command ="echo ${aws_vpc.vpc1.id}>> nullresult"
		}
	}
resource "null_resource" "null22"{
       provisioner "local-exec" {
	      command ="echo ${aws_vpc.vpc2.id}>> nullresult22"
		}
	}
		
*/		  