resource "aws_instance" "web-deploy" {
  ami                         = "ami-0f409bae3775dc8e5"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-04f72fd23f513d4e0"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = "juankeys"
  user_data                   = file("userdata.tpl")

  provisioner "file" {
    source      = "../dist"
    destination = "/tmp/"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./juankeys.pem")
      host        = self.public_dns
    }
  }

  tags = {
    Name = "web-deployment"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "allow ssh on 22 & http on port 80"
  vpc_id      = "vpc-0fde2e0a149541970"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
