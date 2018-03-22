//P: Теперь создадим security group. Это своего рода firewall,
//P: предоставляемый AWS. Добавляя security group к вашему
//P: ресурсы вы разрешаете или запрещаете некоторый сетевой доступ
//P: к нему (как правило, работают они как white-list)

//P: Мы создадим security group для ALB, которая разрешит доступ
//P: на alb для всего мира на 80-ый порт
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

//P: Так же мы создадим security group для ECS инстанса, которая предоставит
//P: доступ к нашему ECS инстансу всем ресурсам внутри VPC
resource "aws_security_group" "ecs_node" {
  name = "${var.resource_prefix}-ecs-node"
  vpc_id = "${data.aws_vpc.default_vpc.id}"

  # access from the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}
