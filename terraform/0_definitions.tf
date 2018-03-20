//P: Terraform is IaC tool with state. It will store state
//P: of your infrastructure after apply. On every new apply
//P: Terraform will load state, scan aws for changes made
//P: without use of Terraform and provide you with diff to
//P: apply to bring your infrastructure in state consistent
//P: with code.

//P: Storage for state created via backend directive. Terraform
//P: supports different storages

//Example with s3
//terraform {
//  backend "s3" {
//    bucket = "tanvd.sandbox.aws.intellij.net"
//    key = "tf_clouds/terraform.tfstate"
//    region = "eu-west-1"
//  }
//  required_version = "0.11.1"
//}

//P: Next you'll need to specify provider. Provider adds support
//P: for sets of resources. For example, adding "aws" provider you
//P: add all types of resources specific for AWS. Now you can manage
//P: them (create, destroy, import) with terraform

//example with aws provider
//provider "aws" {
//  region = "eu-west-1"
//}

//P: Speaking about resources. Basically definitions uses few directives
//P: It is "resource" -- to manage resource via terraform (basically, create)
//P: "data" -- to get state of external resource not managed via terraform
//P: "variable" -- simple variables, types are string, bool, number, list, map
//P: "output" -- store variable in state for later use (and print it to terminal)

//P: Nota Bene: We will skip module system of terraform, it is not necessary in
//P: in simple cases and may bring only a confusion for new person.