//P: We are moving on. Now, we will defined, so called, "container" cluster.
//P: It is abstraction built upon auto scaling groups, representing virtual
//P: cluster executing tasks and running services (all defined as docker containers)
resource "aws_ecs_cluster" "default" {
  name = "${var.resource_prefix}-cluster"
}

//P: ECS cluster works with task definitions -- it is definition of task to
//P: execute. Mostly, it is docker-engine similar definition of task, it's
//P: requirements to CPU and memory. Note, that task definition defines only
//P: task and it's requirements, in terms of "points", but not reqirements to manner
//P: of it's executing.
resource "aws_ecs_task_definition" "default" {
  family = "${var.resource_prefix}-task"
  task_role_arn = "${aws_iam_role.ecs_task_role.arn}"

  container_definitions = <<DEFINITION
[
    {
      "memory": 256,
      "cpu": 256,
      "portMappings": [
        {
          "hostPort": 0,
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "name": "${var.resource_prefix}-nginx-task",
      "image": "nginx:latest"
    }
  ]
DEFINITION
}

resource "aws_ecs_service" "default" {
  name = "${var.resource_prefix}-nginx-service"
  cluster = "${aws_ecs_cluster.default.id}"
  desired_count = "2"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200
  placement_constraints {
    type = "distinctInstance"
  }

  load_balancer {
    container_name = "${var.resource_prefix}-nginx-task"
    container_port = "80"
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  }

  task_definition = "${aws_ecs_task_definition.default.arn}"

  depends_on = ["aws_ecs_task_definition.default"]
}


