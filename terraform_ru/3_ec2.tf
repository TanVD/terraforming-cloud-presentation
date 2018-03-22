//P: Теперь определим launch configuration. Это ресурс terraform, который
//P: используется как шаблон для создания EC2 инстансов

//Определим ssh ключи для доступа к EC2
resource "aws_key_pair" "ec2_ssh_key" {
  key_name = "${var.resource_prefix}-ec2-instance-key"
  public_key = "${file("../keys/ec2_key.pub")}"
}

//P: Нам потребуется определить стандартные IAM роли. Эти роли используются AWS
//P: для контроля доступа. В данном случае, мы даем EC2 инстансу доступ на
//P: коммуникацию с ECS сервисом AWS и возможность становиться ECS Container Instance
//P: (то есть регистрироваться в ECS, как инстанс какого-то кластера)
resource "aws_iam_role" "role_ec2_instance" {
  assume_role_policy = "${data.aws_iam_policy_document.role_ec2_instance_json.json}"
  name = "${var.resource_prefix}-ec2-instance-role"
}

data "aws_iam_policy_document" "role_ec2_instance_json" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "instance_role" {
  role = "${aws_iam_role.role_ec2_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.resource_prefix}-ec2-instance-profile"
  role = "${aws_iam_role.role_ec2_instance.name}"
}



//P: Определим саму launch configuration для EC2 машин.
//P: Мы используем её для создания Auto Scaling Group
resource "aws_launch_configuration" "ec2_launch_config" {
  name_prefix = "${var.resource_prefix}-launch-configuration"
  image_id = "${data.aws_ami.ecs.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.arn}"
  key_name = "${aws_key_pair.ec2_ssh_key.key_name}"
  security_groups = ["${aws_security_group.ecs_node.id}"]

  user_data = <<USERDATA
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.default.name} >> /etc/ecs/ecs.config
USERDATA
  //main block device
  root_block_device {
    volume_size = "20"
    volume_type = "gp2"
  }

  //block device used by ecs by default
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_size = "50"
    volume_type = "gp2"
  }
}

//P: Теперь создадим autoscaling group. Это одна из самых низкоуровных абстракций,
//P: представляющих кластер в AWS. Auto Scaling Group способна автоматически поддерживать
//P: заданное число здоровых инстансов и масштабироваться под нагрузкой.
resource "aws_autoscaling_group" "default" {
  name = "${var.resource_prefix}-autoscaling-group"
  launch_configuration = "${aws_launch_configuration.ec2_launch_config.id}"
  max_size = "2"
  min_size = "2"

  availability_zones = [ "eu-west-1a", "eu-west-1b"]
  vpc_zone_identifier = [ "${aws_subnet.first_subnet.id}", "${aws_subnet.second_subnet.id}"]
}
