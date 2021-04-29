#---------My task 1------------

provider "aws" {
    region     = "us-east-1"
}


resource "aws_instance" "myWebServer" {
    ami                    = "ami-042e8287309f5df03"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.fromWebServer.id]
}

resource "aws_security_group" "fromWebServer" {
  name        = "SGDip"
  description = "mu sg for SG"
 
  ingress {
    description = "SG for WebServer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "SG for WebServer"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "SG for WebServer"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGDipWS"
  }
} 
