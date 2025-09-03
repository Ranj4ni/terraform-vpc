terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-1"
}

# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.client-name}-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.client-name}-igw"
  }
}
# Create a Public Subnet
resource "aws_subnet" "my-public-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "${var.client-name}-public-subnet"
  }
}
# Create a Private Subnet
resource "aws_subnet" "my-private-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "${var.client-name}-private-subnet"
  }
}

# Create a public Route Table
resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "${var.client-name}-route-table"
  }
}
# Create a private Route Table
resource "aws_route_table" "my-private-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.client-name}-private-route-table"
  }
}

# Create Subnet Associations
resource "aws_route_table_association" "my-public-subnet-association" {
  subnet_id      = aws_subnet.my-public-subnet.id
  route_table_id = aws_route_table.my-route-table.id
}

resource "aws_route_table_association" "my-private-subnet-association" {
  subnet_id      = aws_subnet.my-private-subnet.id
  route_table_id = aws_route_table.my-private-route-table.id
}

# Create a Security Group
resource "aws_security_group" "my-security-group" {
  vpc_id = aws_vpc.my-vpc.id

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

  tags = {
    Name = "${var.client-name}-security-group"
  }
}

# Create EC2 Instance
resource "aws_instance" "my-ec2-instance" {
  ami           = "ami-0fa3a4915333e2850" # Amazon Linux 2 AMI
  instance_type = var.my-instance-type
  subnet_id     = aws_subnet.my-public-subnet.id
  key_name      = "linux-hostkey"
  associate_public_ip_address = "true"
  security_groups = [aws_security_group.my-security-group.id]

  tags = {
    Name = "${var.client-name}-ec2-instance"
  }
}
# create another EC2
resource "aws_instance" "my-ec2-instance-2" {
  ami           = "ami-0945610b37068d87a" # Amazon Linux 2 AMI
  instance_type = var.my-instance-type
  subnet_id     = aws_subnet.my-private-subnet.id
  key_name      = "linux-hostkey"
  security_groups = [aws_security_group.my-security-group.id]

  tags = {
    Name = "${var.client-name}-ec2-instance-2"
  }
}
# Create an output file
output "public_ip" {
  value = aws_instance.my-ec2-instance.public_ip
}

output "private_ip" {
  value = aws_instance.my-ec2-instance-2.private_ip
}
