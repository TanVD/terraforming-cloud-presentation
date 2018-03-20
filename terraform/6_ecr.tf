resource "aws_ecr_repository" "nginx_ecr" {
  name = "${var.resource_prefix}-nginx"
}