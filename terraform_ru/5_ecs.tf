//P: Теперь остается создать сам ECS кластер.
//P: ECS это кластер виртуальных вычислительных ресурсов, способный выполнять
//P: задачи, описанные как Docker контейнеры. Мы рассматриваем ситуацию, когда
//P: ECS определен поверх Auto Scaling Group (то есть вычислительные ресурсы
//P: он берет из ASG)
resource "aws_ecs_cluster" "default" {
  name = "${var.resource_prefix}-cluster"
}

//P: Создадим стандарту IAM роль для ECS задачи
resource "aws_iam_role" "ecs_task_role" {
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_role_json.json}"
  name = "${var.resource_prefix}-ecs-task-role"
}

data "aws_iam_policy_document" "ecs_task_role_json" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

//P: ECS кластер работает с task definition -- это определение задачи для ECS
//P: в терминах близких к Docker engine. К примеру, в определении описываются
//P: требования задачи к CPU, Memory и конечно, Docker контейнер для выполнения.
//P: Заметим, что task definition определяет саму задачу, но не то, как она должна
//P: выполняться (по расписанию ли, постоянно, только один раз и т.д. и т.п.)
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

//P: Наконец, определим ecs_service. Это как раз определения того, как
//P: должна выполняться задача. ecs_service будует автоматически перезапускать
//P: контейнер, если он завершается. Как правило, его использует для web серверов
//P: и других задач, в которых завершение контейнера является аварией, а приложение
//P: должно работать постоянно.
//P: Как ecs_service мы и запустим nginx
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


