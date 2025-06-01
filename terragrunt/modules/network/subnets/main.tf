# Public Subnet (updated to use for_each)
resource "aws_subnet" "public_subnet" {
  for_each = var.subnet_cidrs_public
  
  vpc_id            = var.aws_vpc_id
  cidr_block        = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-subnet-${each.key}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.project}-cluster" = "owned"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_a" {
  domain = "vpc"
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
}

# # NAT Gateways in Public Subnets
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_subnet[keys(aws_subnet.public_subnet)[0]].id
  tags = {
        Name = "${var.project}-nat-gateway-a"
    }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_subnet[keys(aws_subnet.public_subnet)[1]].id
  tags = {
        Name = "${var.project}-nat-gateway-b"
  }
}

# Private Subnet (also updated to use for_each)
resource "aws_subnet" "private_subnet" {
  for_each = var.subnet_cidrs_private
  
  vpc_id            = var.aws_vpc_id
  cidr_block        = each.value
  availability_zone = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-private-subnet-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.project}-cluster" = "owned"
  }
}
# Private Route Tables for Each AZ
resource "aws_route_table" "private_a" {
  vpc_id = var.aws_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }
  tags = {
        Name = "${var.project}-private-route-table-a"
    }
}

resource "aws_route_table" "private_b" {
  vpc_id = var.aws_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }
  tags = {
        Name = "${var.project}-private-route-table-b"
    }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = var.aws_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = "${var.project}-public-route-table"
  }
}

# Associate Private Subnets with Their Route Tables - NAT
resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private_subnet
  
  subnet_id      = each.value.id
  route_table_id = each.key == keys(var.subnet_cidrs_private)[0] ? aws_route_table.private_a.id : aws_route_table.private_b.id
}

# Associate Public Subnet with Route Table (updated for for_each)
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public_subnet
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

