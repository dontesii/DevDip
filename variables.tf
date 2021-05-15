variable "region" {
  type = string
  default = "us-east-1"
}

variable "image_id" {
  type = string
  default = "ami-09e67e426f25ce0d7"
}

variable "ec2_instance_port" {
  type = number
  default = 80
}

