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
