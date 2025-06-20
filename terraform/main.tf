resource "aws_default_vpc" "default" {

}
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

resource "aws_instance" "nginx_ec2" {
  ami                    = "ami-09e6f87a47903347c" 
  instance_type          = "t2.micro"
  key_name               = var.key_name 
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

      user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install nginx -y
              sudo systemctl enable nginx
              sudo systemctl start nginx

              EOF


  tags = {
    Name = "Terraform-Nginx-Instance"
  }
}

output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.nginx_ec2.public_ip
}
