//P: Первым делом, мы создадим сетевую инфраструктуру
//P: Мы используем default VPC и создадим в ней две подсети в
//P: разных availibility zones

//P: Мы используем default Virtual Private Cloud и опускаем
//P: все сложности настройки gateway
data "aws_vpc" "default_vpc" {
  id = "vpc-68e3b00d"
}

//P: Так же мы создаем две подсети и указываем им разные AZ
resource "aws_subnet" "first_subnet" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "second_subnet" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"
  cidr_block = "10.0.20.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1b"
}

//TODO-tanvd manually need to change gateaway because of shared VPC