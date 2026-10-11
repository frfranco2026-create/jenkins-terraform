# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "frfranco-terraform-state-2026"
    key          = "ec2-example/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-west-2" # change to your preferred region
}

# Latest standard Amazon Linux 2023 AMI, published by AWS as a public SSM parameter
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "example" {
  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = "t2.micro" # free-tier eligible

  tags = {
    Name = "terraform-example-instance"
  }

  # New AMI releases would otherwise force a replacement on every run.
  # To pick up a newer AMI on purpose: terraform apply -replace=aws_instance.example
  lifecycle {
    ignore_changes = [ami]
  }
}

output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
