resource "aws_alb" "alb" {
  name = "${var.resource_prefix}-alb"
  subnets = [
    "${aws_subnet.first_subnet.id}",
    "${aws_subnet.second_subnet.id}"]
  security_groups = ["${aws_security_group.alb_security_group.id}"]
}

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

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
    type = "forward"
  }
}