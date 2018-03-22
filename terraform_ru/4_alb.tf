//P: Теперь создадим ALB. Он будет балансировать HTTP запросы
//P: между двумя созданными нами EC2 иинстансами

resource "aws_alb" "alb" {
  name = "${var.resource_prefix}-alb"
  subnets = [
    "${aws_subnet.first_subnet.id}",
    "${aws_subnet.second_subnet.id}"]
  security_groups = ["${aws_security_group.alb_security_group.id}"]
}


//P: Так же создадим Target Group -- это группа, представляющая собой
//P: приложения, на который будет перенаправлять нагрузка. В данном
//P: случае нагрузка будет перенаправлять на 80 порт зарегистрированных
//P: вычислительных ресурсов
resource "aws_alb_target_group" "alb_target_group" {
  name = "${var.resource_prefix}-alb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.default_vpc.id}"

  health_check {
    path = "/"
    interval = 60
  }

  depends_on = ["aws_alb.alb"]
}

//P: Наконец, определим ALB listener -- это внешний интерфейс ALB.
//P: Теперь весь трафик попадающих на 80 порт ALB будет перенаправляться
//P: на target group определенную выше
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
    type = "forward"
  }
}