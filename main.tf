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

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into the instance (e.g. 1.2.3.4/32)"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be a valid CIDR block, e.g. 1.2.3.4/32."
  }
}

variable "key_name" {
  description = "Name of an existing EC2 key pair to install on the instance for SSH"
  type        = string
  default     = "terraform-example-instance"
}

# Latest standard Amazon Linux 2023 AMI, published by AWS as a public SSM parameter
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "ssh" {
  name        = "terraform-example-ssh"
  description = "Allow SSH only from a single trusted IP"

  ingress {
    description = "SSH from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t2.micro" # free-tier eligible
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]

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
