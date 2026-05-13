# Private Subnet (Mid-Tier) - nur über Public Subnet erreichbar
resource "aws_subnet" "midtier_subnet" {
  vpc_id            = data.aws_vpc.pond_vpc.id
  cidr_block        = "172.31.48.0/20"  # Neuer freier CIDR-Block
  availability_zone = "eu-central-1c"    # Gleiche AZ wie public subnet

  # KEINE Public IP vergeben
  map_public_ip_on_launch = false

  tags = {
    Name = "midtier-private-subnet"
    Tier = "midtier"
  }
}

# Route Table für Mid-Tier Subnet (keine Internet-Route!)
resource "aws_route_table" "midtier_rt" {
  vpc_id = data.aws_vpc.pond_vpc.id

  tags = {
    Name = "midtier-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "midtier_rta" {
  subnet_id      = aws_subnet.midtier_subnet.id
  route_table_id = aws_route_table.midtier_rt.id
}

# Security Group für Mid-Tier EC2
resource "aws_security_group" "midtier_sg" {
  name        = "midtier-sg"
  description = "Security group for mid-tier EC2 - only accessible from public subnet"
  vpc_id      = data.aws_vpc.pond_vpc.id

  # SSH nur vom Public Subnet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/20"]  # Public Subnet CIDR
    description = "SSH from public subnet"
  }

  # ICMP (Ping) vom Public Subnet
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["172.31.0.0/20"]
    description = "ICMP from public subnet"
  }

  # HTTP vom Public Subnet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/20"]
    description = "HTTP from public subnet"
  }

  # HTTPS vom Public Subnet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/20"]
    description = "HTTPS from public subnet"
  }

  # Ausgehender Traffic innerhalb der VPC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.31.0.0/16"]  # Gesamte VPC
    description = "Allow all outbound within VPC"
  }

  tags = {
    Name = "midtier-sg"
  }
}

# EC2 Instance in Mid-Tier Subnet
resource "aws_instance" "midtier_ec2" {
  ami           = "ami-0084a47cc718c111a"  # Ubuntu
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.midtier_subnet.id
  key_name      = var.ec2_key_name

  vpc_security_group_ids = [aws_security_group.midtier_sg.id]

  # KEINE Public IP
  associate_public_ip_address = false

  tags = {
    Name = "midtier-ec2-instance"
    Tier = "midtier"
  }
}

# Outputs
output "midtier_subnet_id" {
  value       = aws_subnet.midtier_subnet.id
  description = "ID of the mid-tier subnet"
}

output "midtier_ec2_private_ip" {
  value       = aws_instance.midtier_ec2.private_ip
  description = "Private IP of mid-tier EC2 instance"
}

output "midtier_ssh_command" {
  value       = "ssh -i ~/.ssh/${var.ec2_key_name}.pem -J ubuntu@${aws_instance.public_ec2.public_ip} ubuntu@${aws_instance.midtier_ec2.private_ip}"
  description = "SSH command via jump host (bastion)"
}

output "midtier_access_instructions" {
  value = <<-EOT
    # Von der Public EC2 aus:
    ssh -i ~/.ssh/${var.ec2_key_name}.pem ubuntu@${aws_instance.public_ec2.public_ip}

    # Dann auf der Public EC2:
    ping ${aws_instance.midtier_ec2.private_ip}
    ssh ubuntu@${aws_instance.midtier_ec2.private_ip}
    curl http://${aws_instance.midtier_ec2.private_ip}
  EOT
  description = "Instructions to access mid-tier instance"
}
