# Terraform Configuration for AWS
provider "aws" {
  region = "us-east-1" # Specify your desired AWS region
}

# Create a VPC
resource "aws_vpc" "nextwork_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "NextWork-VPC"
  }
}

# Create a Public Subnet
resource "aws_subnet" "nextwork_public_subnet" {
  vpc_id                  = aws_vpc.nextwork_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "NextWork-Public-Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "nextwork_igw" {
  vpc_id = aws_vpc.nextwork_vpc.id

  tags = {
    Name = "NextWork-IGW"
  }
}

# Attach a Route Table to the Subnet
resource "aws_route_table" "nextwork_public_rt" {
  vpc_id = aws_vpc.nextwork_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nextwork_igw.id
  }

  tags = {
    Name = "NextWork-Public-RT"
  }
}

resource "aws_route_table_association" "nextwork_rt_assoc" {
  subnet_id      = aws_subnet.nextwork_public_subnet.id
  route_table_id = aws_route_table.nextwork_public_rt.id
}

# Create a Security Group
resource "aws_security_group" "nextwork_sg" {
  vpc_id = aws_vpc.nextwork_vpc.id

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "NextWork-SG"
  }
}

# Launch an EC2 Instance
resource "aws_instance" "nextwork_instance" {
  ami           = "ami-0a91cd140a1fc148a" # Amazon Linux 2023 AMI for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.nextwork_public_subnet.id
  security_groups = [
    aws_security_group.nextwork_sg.name
  ]

  associate_public_ip_address = true

  tags = {
    Name = "Instance-NextWork-VPC-Project"
  }
}
