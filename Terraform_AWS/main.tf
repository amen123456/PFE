// To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

// Create Key Pair for Connecting EC2 via SSH
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

// Save PEM file locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = "${path.module}/${var.key_name}.pem"
}

// Create a security group
resource "aws_security_group" "sg_ec2" {
  name        = "sg_ec2"
  description = "Security group for EC2"
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

  ingress {
    from_port   = 27017
    to_port     = 27017
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

resource "aws_instance" "public_instance" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]

  tags = {
    Name = "DevOps"
  }

  root_block_device {
    volume_size = 150
    volume_type = "gp2"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update the package list and install updates
              sudo apt-get update -y

              # Install Git
              sudo apt-get install git -y

              # Install Docker
              sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update -y
              sudo apt-get install docker-ce -y
              sudo usermod -aG docker ubuntu

              # Install Apache
              sudo apt-get install apache2 -y

              # Install Node.js
              curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
              sudo apt-get install -y nodejs

              # Install MongoDB
              sudo apt-get install -y mongodb

              # Start MongoDB service
              sudo systemctl start mongodb
              sudo systemctl enable mongodb

              EOF
}
