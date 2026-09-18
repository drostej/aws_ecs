locals {
  ec2_private_key_path = var.ec2_private_key_path != null ? var.ec2_private_key_path : "${path.module}/ec2-sandbox-key.pem"
}

resource "tls_private_key" "ec2_access" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "ec2_private_key_pem" {
  content         = tls_private_key.ec2_access.private_key_pem
  filename        = local.ec2_private_key_path
  file_permission = "0400"
}

resource "aws_key_pair" "ec2_access" {
  key_name   = var.ec2_key_name
  public_key = tls_private_key.ec2_access.public_key_openssh
}

# EC2 Instance in public subnet
resource "aws_instance" "public_ec2" {
  ami           = "ami-0084a47cc718c111a" # Amazon Linux 2023 eu-central-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

  key_name = aws_key_pair.ec2_access.key_name

  vpc_security_group_ids = [aws_security_group.ec2_public_sg.id]

  # Public IP zuweisen
  associate_public_ip_address = true

  tags = {
    Name = "public-ec2-instance"
  }
}

# Security Group für EC2
resource "aws_security_group" "ec2_public_sg" {
  name        = "ec2-public-sg"
  description = "Security group for public EC2 instance"
  vpc_id      = data.aws_vpc.pond_vpc.id

  # SSH von überall (für Produktion: auf deine IP beschränken!)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from anywhere"
  }

  # Ausgehender Traffic erlaubt
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "ec2-public-sg"
  }
}

# Variable für SSH Key Name
variable "ec2_key_name" {
  description = "Name of the SSH key pair for EC2 access"
  type        = string
  default     = "ec2-sandbox-key"
}

variable "ec2_private_key_path" {
  description = "Lokaler Pfad für den von Terraform erzeugten privaten SSH-Schlüssel"
  type        = string
  default     = null
  nullable    = true
}

# Output der Public IP
output "ec2_public_ip" {
  value       = aws_instance.public_ec2.public_ip
  description = "Public IP address of the EC2 instance"
}

output "ec2_ssh_command" {
  value       = "ssh -i ${local.ec2_private_key_path} ec2-user@${aws_instance.public_ec2.public_ip}"
  description = "SSH command to connect to the instance"
}

output "ec2_private_key_path" {
  value       = local_sensitive_file.ec2_private_key_pem.filename
  description = "Lokaler Pfad der von Terraform erzeugten privaten PEM-Datei"
  sensitive   = true
}

