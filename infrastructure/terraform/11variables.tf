data "aws_vpc" "pond_vpc" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  public_subnet_cidr  = cidrsubnet(data.aws_vpc.pond_vpc.cidr_block, 4, 4)
  midtier_subnet_cidr = cidrsubnet(data.aws_vpc.pond_vpc.cidr_block, 4, 3)
  subnet_az           = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = data.aws_vpc.pond_vpc.id
  cidr_block              = local.public_subnet_cidr
  availability_zone       = local.subnet_az
  map_public_ip_on_launch = true

  tags = {
    Name = "pond-public-subnet"
    Tier = "public"
  }
}
