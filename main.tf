# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "frfranco-terraform-state-2026"
    key            = "ec2-example/terraform.tfstate"
    region         = "us-west-2"
    use_lockfile   = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-west-2" # change to your preferred region
}

# Grab the latest Amazon Linux 2023 AMI so you don't have to hardcode an ID
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro" # free-tier eligible

  tags = {
    Name = "terraform-example-instance"
  }
}

output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
