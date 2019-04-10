# resource creating vpc main
resource "aws_vpc" "main" {
cidr_block = "${var.cidr_block}"
enable_dns_hostnames = true

tags = {
    Name = "bal"
  }
}

# Creating Public subnet
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnetcidr_block}"

  tags = {
    Name = "bal"
  }
}
# resource private subnet
resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnetcidr_block}"

  tags = {
    Name = "bal"
  }
}
# resource internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "bal"
  }
}

#####Resource Route public Table######
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  

  tags {
    Name = "public"
  }

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

#####resource private table ############
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "custom private"
  }

}
##############Table association with public############

resource "aws_route_table_association" "public" {
       subnet_id= "${aws_subnet.public.id}"
        route_table_id = "${aws_route_table.public.id}"

}
#########Creating Resource security group 

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  vpc_id     = "${aws_vpc.main.id}"
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ALL  HHTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ALL  HHTP access
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create key pair resource
#resource "aws_key_pair" "mykey" {
#key_name   = "mykey"
#public_key = "${file("~/.ssh/bal.pub")}"

#}


########## Creating Instance ##############
# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "jenkins"

resource "aws_instance" "my_jenkins" {
   ami = "ami-01419b804382064e4"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.public.id}"
   associate_public_ip_address = true
   #key_name = "${aws_key_pair.mykey.key_name}"
   vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
   
   tags {
     Name = "bal jenkins"
     }
      user_data = <<-EOF
                  yum remove java -y
                  yum install java-1.8.0-openjdk -y

                  echo "Install Jenkins stable release"
                  wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
                  rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
                  yum install jenkins -y
                  EOF
#     user_data = "${file("install_jenkins.sh")}"

}
       
resource "aws_instance" "my_jenkins2" {
   ami = "ami-01419b804382064e4"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.public.id}"
   associate_public_ip_address = true
   #key_name = "${aws_key_pair.mykey.key_name}"
   vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]

    tags {
     Name = "bal jenkins2"
     }
}


resource "aws_eip" "default" {
  instance = "${aws_instance.my_jenkins.id}"
  vpc      = true
}
