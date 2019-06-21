resource "aws_elb" "elb" {
  name = "elb"
  subnets = ["${aws_subnet.main-public.id}"]
  security_groups = ["${aws_security_group.elb-securitygroup.id}"]
 listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 2  # for demo purpose, keeping low interval value. Standard timeout is 3
    target = "HTTP:80/index.html"
    interval = 5 # for demo purpose, keeping low interval value. Standard interval is 30
  }

  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
  tags {
    Name = "elb"
  }
}