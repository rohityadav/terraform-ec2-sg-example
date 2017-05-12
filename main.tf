provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  default = "80"
}

variable "ssh_port" {
  default = "22"
}

resource "aws_instance" "ec2-instance" {
  ami = "ami-c58c1dd3"
  instance_type = "t2.micro"
  key_name = "test-ec2"
  vpc_security_group_ids = ["${aws_security_group.sg-instance.id}"]

  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install httpd -y
  service httpd start
  EOF

  tags {
    Name="terraform-ec2-sg-example"
  }
}

resource "aws_security_group" "sg-instance" {
  name = "terraform-sg"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = "${aws_instance.ec2-instance.public_ip}}"
}