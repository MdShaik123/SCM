data "aws_availability_zones" "available" {
  state = "available"
}


#create VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames ="true"

  tags = {
    Name = "Prod-VPC"
  }
}

#create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}

#create Elastic IP
resource "aws_eip" "eip" {
  vpc      = true
}

#create Nat gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "Prod-NAT-gateway"
  }
}

#create public Subnets
resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  cidr_block = element(var.public_cidr_range,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "Prod-Public-subnet-${count.index+1}"
  }
}

#create private Subnets
resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.private_cidr_range,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "Prod-Private-subnet-${count.index+1}"
  }
}

#create data Subnets
resource "aws_subnet" "data" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.data_cidr_range,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "Prod-Data-subnet-${count.index+1}"
  }
}

#create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route"
  }
}

#create private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "Private-Route"
  }
}

#Add public subnet association
resource "aws_route_table_association" "public" {
  count =length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}

#Add private subnet association
resource "aws_route_table_association" "private" {
  count =length(aws_subnet.private[*].id)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}

#Add data subnet association
resource "aws_route_table_association" "data" {
  count =length(aws_subnet.private[*].id)
  subnet_id      = element(aws_subnet.data[*].id,count.index)
  route_table_id = aws_route_table.private.id
}