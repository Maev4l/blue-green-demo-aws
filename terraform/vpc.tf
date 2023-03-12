
locals {
  public_subnets_cidr = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
  ]
  private_subnets_cidr = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
  ]
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name : "demo-blue-green" }
}

resource "aws_subnet" "public_subnet" {
  count             = var.public_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(local.public_subnets_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  tags = {
    Name = "demo-blue-green-public-subnet"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "demo-blue-green"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "demo-blue-green-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = var.public_subnet_count
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(local.private_subnets_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  tags = {
    Name = "demo-blue-green-private-subnet"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "demo-blue-green-private-rt"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = var.private_subnet_count
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

// Make ECR service accessible from the private subnets with VPC endpoints
// see: https://aws.amazon.com/blogs/compute/setting-up-aws-privatelink-for-amazon-ecs-and-amazon-ecr/
resource "aws_security_group" "sg_vpc_endpoint" {
  name        = "demo-blue-green-vpc-endpoint-sg"
  description = "Security group VPC endpoints"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_https_vpc_endpoint" {
  count = var.private_subnet_count

  security_group_id = aws_security_group.sg_vpc_endpoint.id
  cidr_ipv4         = element(local.private_subnets_cidr, count.index)
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_endpoint" "ecr_docker" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnet[*].id
  security_group_ids  = [aws_security_group.sg_vpc_endpoint.id]

  tags = {
    Name = "demo-blue-green-private-vpc-endpoint-ecr-docker"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnet[*].id
  security_group_ids  = [aws_security_group.sg_vpc_endpoint.id]

  tags = {
    Name = "demo-blue-green-private-vpc-endpoint-ecr-api"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private_route_table.id]
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect : "Allow",
      Action : "*",
      Principal : "*",
      Resource : "*"
    }]
  })

  tags = {
    Name = "demo-blue-green-private-vpc-endpoint-s3"
  }
}
