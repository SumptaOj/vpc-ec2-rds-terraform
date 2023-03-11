// Create key pair
// Run the below code in the terraform directory to create keypair
# ssh-keygen -t rsa -b 4096 -m pem -f terra_kp && openssl rsa -in terra_kp -outform pem

// Make the key an aws key
resource "aws_key_pair" "kp" {
  key_name   = "terra_kp"
  public_key = file("terra_kp.pub")
}

// Lookup the latest Amazon Linux 2 AMI 
data "aws_ami" "amazon-linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

// Create a launch template
resource "aws_launch_template" "web" {
  name_prefix            = "web-"
  image_id               = data.aws_ami.amazon-linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.kp.key_name
  user_data = (base64encode(templatefile("user_data.tftpl", {
    rds_endpoint = "${aws_db_instance.rds.endpoint}"
    user         = var.db_username
    password     = var.db_password
    dbname       = var.db_name
    bucket_name  = aws_s3_bucket.user_data.id
  })))
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 10
      delete_on_termination = true
      volume_type           = "gp2"
    }
  }
  monitoring {
    enabled = true
  }

  lifecycle {
    create_before_destroy = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_s3_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.project_name
  }

}

// Create autoscaling group
resource "aws_autoscaling_group" "web" {
  name             = "${aws_launch_template.web.name}-asg"
  desired_capacity = 1
  max_size         = 3
  min_size         = 1
  vpc_zone_identifier = [
    "${aws_subnet.web_public_subnet1.id}",
    "${aws_subnet.web_public_subnet2.id}"
  ]
  target_group_arns         = ["${aws_lb_target_group.web_tg.arn}"]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  tag {
    key                 = "Name"
    value               = "ec2_rds_instance"
    propagate_at_launch = true
  }

}


// Create Application load balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets = [
    "${aws_subnet.web_public_subnet1.id}",
    "${aws_subnet.web_public_subnet2.id}"
  ]

  tags = var.project_name
}

// Create target group
resource "aws_lb_target_group" "web_tg" {
  name        = "web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    interval            = 120
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 90
    protocol            = "HTTP"
    matcher             = "200"
  }

}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}



