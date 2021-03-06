provider "aws" {
  region = var.region
}
#--------------------------------------------------
variable "app_subnets" { 
    type        = list(string) 
    description = "App subnets id" 
    default     = ["subnet-5b00923d", "subnet-9d7954d0", "subnet-58fca856", "subnet-55891174", "subnet-fbb415ca", "subnet-53dc420c"]
} 
#--------------------------------------------------
resource "aws_security_group" "alb-sec-group" {
  name        = "alb-sec-group"
  description = "Security Group for the ELB (ALB)"
  dynamic "ingress" {
    for_each  = ["80", "443", "22", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "alb SecurityGroup"
    Owner = "Admon"
  }
}
#--------------------------------------------------
data "aws_availability_zones" "available" {}
#--------------------------------------------------
resource "aws_security_group" "asg_sec_group" {
  name = "asg_sec_group"
  description = "Security Group for the ASG"
#   tags = {
#     name = "name"
#   }
  egress {
    from_port = 0
    protocol = "-1" // ALL Protocols
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    security_groups = [aws_security_group.alb-sec-group.id]
  }
  tags = {
    Name  = "asg SecurityGroup"
    Owner = "Admon"
  }
}
# --------------------------------------------------
# Create the ASG
 resource "aws_autoscaling_group" "Practice_ASG" {
  name                      = "ASG-${aws_launch_template.web.name}"
  max_size                  = 3
  min_size                  = 2
  min_elb_capacity          = 2
  health_check_grace_period = 300 
  health_check_type         = "ELB" 
  vpc_zone_identifier       = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]  
  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }
  target_group_arns = [aws_lb_target_group.asg.arn]
  dynamic "tag" {
    for_each = {
      Name   = "WebServer"
      Owner  = "Admon"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  depends_on = [aws_lb.ELB]
  lifecycle {
    create_before_destroy = true
  }
}
#--------------------------------------------------
resource "aws_lb" "ELB" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.app_subnets
  security_groups    = [aws_security_group.alb-sec-group.id]
}
#--------------------------------------------------
resource "aws_lb_target_group" "asg" {
  name = "asg-example"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = "vpc-aa7ed0d7"
}
#--------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ELB.arn 
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
#     type            = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "404: page not found"
#       status_code  = 404
    
  }
}
#--------------------------------------------------
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
#--------------------------------------------------
resource "aws_launch_template" "web" {
  name          = "web"
  image_id      = "ami-09e67e426f25ce0d7"
  instance_type = "t3.micro"
  key_name      = "keyAWS"
  user_data     = filebase64("${path.module}/install_nginx.sh")
  disable_api_termination = true
  ebs_optimized         = true
    cpu_options {
    core_count       = 1
    threads_per_core = 2  
  }
  credit_specification {
    cpu_credits = "standard"
  }
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 10
    }
  }
  placement {
    availability_zone = "us-east-1"
  }
  instance_initiated_shutdown_behavior = "terminate"
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  vpc_security_group_ids = [aws_security_group.alb-sec-group.id]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "MyWarServer"
    }
    
  }
}

#--------------------------------------------------
data "aws_instances" "webserver_instans" {
  instance_tags = {
    Name = "WebServer"
  }

  filter {
    name   = "tag:Name"
    values = ["WebServer"]
  }
  depends_on = [aws_autoscaling_group.Practice_ASG]
}

output "aws_instans_public_ip" {
    value = data.aws_instances.webserver_instans.public_ips
}
#--------------------------------------------------
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}
