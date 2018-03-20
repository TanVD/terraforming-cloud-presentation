provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "tanvd.sandbox.aws.intellij.net"
    key = "tf_clouds/terraform.tfstate"
    region = "eu-west-1"
  }
  required_version = "0.11.1"
}
