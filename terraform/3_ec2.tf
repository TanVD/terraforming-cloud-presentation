//P: Next we need to define launch configuration. It is a terraform _resource_
//P: which we will use as template for all created later ec2 machines

//Define key pair resource.
//This resource will be used by ec2 machines to setup
//config of ssh connection
resource "aws_key_pair" "ec2_ssh_key" {
  key_name = "${var.resource_prefix}-ec2-instance-key"
  public_key = "${file("../keys/ec2_key.pub")}"
}

//P: Define launch configuration itself for your ec2 machines
//P: This configuration is a template, which can be applied to machine
//P: We will use it for creation of Auto Scaling Group
resource "aws_launch_configuration" "ec2_launch_config" {
  name_prefix = "${var.resource_prefix}-launch-configuration"
  image_id = "ami-4cbe0935"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.ec2_ssh_key.key_name}"
  //TODO-tanvd ????
  security_groups = ["${aws_security_group.alb_security_group.id}"]

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

//P: Now we will setup autoscaling group resource. It is lowest abstraction of cluster in AWS -- group
//P: of machines, health of which is monitored automatically. Auto Scaling Group can scale under load
//P: and a lot more, but we'll skip this part.

//Define auto scaling group resource. This resource is cluster of ec2 machines,
//which is monitored and scaled automatically
resource "aws_autoscaling_group" "default" {
  name = "${var.resource_prefix}-autoscaling-group"
  launch_configuration = "${aws_launch_configuration.ec2_launch_config.id}"
  max_size = "2"
  min_size = "2"
}
