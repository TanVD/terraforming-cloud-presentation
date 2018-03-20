variable "resource_prefix" {
  default = "tanvd-tf-clouds"
}

data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn-ami-*-ecs-optimized"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }

  owners = ["amazon"]
}