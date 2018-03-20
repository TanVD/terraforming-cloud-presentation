//P: First of all, we need to establish network infrastructure.
//P: We will use default VPC and create in it two subnets to get
//P: two availibility zones


//P: We will use default Virtual Private Cloud, so we will skip
//P: all problems with configuring gateaways,
data "aws_vpc" "default_vpc" {
  id = "vpc-68e3b00d"
}

//P: Next, we will create two subnets, and specify for them different
//P: avalability zones.
resource "aws_subnet" "first_subnet" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"
  cidr_block = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "second_subnet" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"
  cidr_block = "10.10.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1b"
}