resource "aws_launch_configuration" "launch-apache-instance" {
  name_prefix          = "launch-apache-instance"
  image_id             = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type        = "t2.micro"
  key_name             = "${aws_key_pair.mykeypair.key_name}"
  security_groups      = ["${aws_security_group.instance-sg.id}"]
  user_data            = "#!/bin/bash\napt-get update\napt-get -yq install apache2 php libapache2-mod-php\nHOSTNAME=`hostname`\necho 'Hello World !! This is : '$HOSTNAME > /var/www/html/index.html"
  lifecycle              { create_before_destroy = true }
}

resource "aws_autoscaling_group" "autoscaling" {
  name                 = "autoscaling"
  vpc_zone_identifier  = ["${aws_subnet.main-private.id}"]
  launch_configuration = "${aws_launch_configuration.launch-apache-instance.name}"
  min_size             = 2
  max_size             = 5
  health_check_grace_period = 300
  health_check_type = "ELB"
  load_balancers = ["${aws_elb.elb.name}"]
  force_delete = true

  tag {
      key = "Name"
      value = "NerOps instance"
      propagate_at_launch = true
  }
}