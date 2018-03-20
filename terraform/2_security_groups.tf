//P: Next we will create security group. It is a kind of a firewall,
//P: used by AWS for all instances. Setting up security group you
//P: provide white lists for network connection in your system.

resource "aws_security_group" "alb_security_group" {
  name = "${var.resource_prefix}-alb-security-group"
  vpc_id = "${data.aws_vpc.default_vpc.id}"

  //access to http port by tcp for all world
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  //outbound access for all world
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}
