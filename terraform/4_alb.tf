//P: Now we setting up ALB. It will balance load between two
//P: ec2 instances we created.

//P: We define ALB itself, it's security group and subnets it is
//P: connected to
resource "aws_alb" "alb" {
  name = "${var.resource_prefix}-alb"
  subnets = [
    "${aws_subnet.first_subnet.id}",
    "${aws_subnet.second_subnet.id}"]
  security_groups = ["${aws_security_group.alb_security_group.id}"]
}

//P: Next, we create "target_group" -- group of targets for balancing
//P: for alb. In this case, all load will be redirected to port 80
//P: of targets registered in this target group
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

//P: And finally we define ALB listener -- external interface of ALB.
//P: Now, all traffic incoming to port 80 of ALB will be redirected to
//P: target group defined above
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
    type = "forward"
  }
}