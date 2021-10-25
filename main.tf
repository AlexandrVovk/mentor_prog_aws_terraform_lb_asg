terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
    "amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# data "aws_availability_zones" "north" {
#   all_availability_zones = true
# }

# data "aws_availability_zones" "north" {
#   all_availability_zones = true
# }

data "aws_subnets" "example" {}

output "suboutput" {
  value = data.aws_subnets.example.ids
}

resource "aws_instance" "app" {
  # for_each      = data.aws_subnets.example.ids
  count         = length(data.aws_subnets.example.ids)
  ami           = data.aws_ami.ami.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnets.example.ids[count.index % length(data.aws_subnets.example.ids)]
  user_data     = <<EOF
  #!/bin/bash
sudo amazon-linux-extras install -y nginx1
sudo systemctl start nginx.service
echo $(hostname -I) > /usr/share/nginx/html/index.html
EOF
}

# resource "aws_instance" "ins_1" {
#   for_each      = data.aws_subnets.example.ids
#   ami           = data.aws_ami.ami.id
#   instance_type = "t3.micro"
#   key_name      = "mac-key"
#   # vpc_security_group_ids = [aws_security_group.privat.id]
#   subnet_id = each.value
#
#   # tags = {
#   #   Name = "PrivatEc2"
#   # }
# }

# output "az_all" {
#   value = data.aws_availability_zones.north.names
# }
