
provider "aws" {
  region = "us-east-1"
}
module "vpc1" {
  source = "terraform-aws-modules/vpc/aws"

  name = "flipkart-vpc-dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
# Create a Security Group
resource "aws_security_group" "my-security-group" {
  vpc_id = module.vpc1.vpc_id

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
    Name = "terra-module-sg"
  }
}
# Create EC2 Instance
resource "aws_instance" "web1" {
  ami           = "ami-00ca32bbc84273381" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = module.vpc1.public_subnets[0]
  key_name      = "linux"
  associate_public_ip_address = "true"
  security_groups = [aws_security_group.my-security-group.id]

  tags = {
    Name = "terra-module-ec2-instance"
  }
}
# Create an output file
output "web1-public_ip" {
  value = aws_instance.web1.public_ip
}
output "web1-private_ip" {
  value = aws_instance.web1.private_ip
}
