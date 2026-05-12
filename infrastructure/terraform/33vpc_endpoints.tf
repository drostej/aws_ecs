# VPC Endpoints for ECR access from ECS tasks

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = data.aws_vpc.pond_vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.pond_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}

# Get subnet IDs for the VPC
data "aws_subnets" "pond_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.pond_vpc.id]
  }
}

# ECR API VPC Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = data.aws_vpc.pond_vpc.id
  service_name        = "com.amazonaws.eu-central-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = data.aws_subnets.pond_subnets.ids

  security_group_ids = [
    aws_security_group.vpc_endpoints_sg.id
  ]

  tags = {
    Name = "ecr-api-endpoint"
  }
}

# ECR DKR VPC Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = data.aws_vpc.pond_vpc.id
  service_name        = "com.amazonaws.eu-central-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = data.aws_subnets.pond_subnets.ids

  security_group_ids = [
    aws_security_group.vpc_endpoints_sg.id
  ]

  tags = {
    Name = "ecr-dkr-endpoint"
  }
}

# S3 VPC Endpoint (Gateway type for ECR image layers)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.aws_vpc.pond_vpc.id
  service_name      = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "s3-gateway-endpoint"
  }
}

# Associate S3 endpoint with route tables
data "aws_route_tables" "pond_route_tables" {
  vpc_id = data.aws_vpc.pond_vpc.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_route_table_association" {
  for_each = toset(data.aws_route_tables.pond_route_tables.ids)

  route_table_id  = each.value
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
