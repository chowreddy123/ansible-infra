provider "aws" {
  region = "us-east-1"
}
#-------------------------------------aws vpc---------------------------------
resource "aws_vpc" "my_vpc_network" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    name = "TerraformVPC"
  }
}
#------------------------------------aws IGW----------------------------------
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc_network.id

  tags = {
    name ="TerraformIGW"
  }
}
#----------------------------------aws subnet---------------------------------
resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.my_vpc_network.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    name ="TerraformSubnet"
  }
}
#----------------------------aws routeTable-----------------------------------

resource "aws_route_table" "my_route" {
  vpc_id = aws_vpc.my_vpc_network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    name = "TerraformRouteTable"
  }
}
resource "aws_route_table_association" "public_route" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my_route.id
}

#---------------------------aws key-pair----------------------------------------

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.my_key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}
#--------------------------------------aws instance-------------------------------
resource "aws_instance" "aws_instance" {
  ami = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
  key_name = "my-key-pair"
#  vpc_security_group_ids = ["sg-0b075493ec4ade986"]
#  subnet_id = aws_subnet.public_subnet.id

  tags = {
    name ="my-instance"
  }
}