locals{
  pvt_subnets_list = [aws_subnet.priv_sub1.id, aws_subnet.priv_sub2.id]
  pub_subnets_cidr_list = [aws_subnet.pub_sub1.cidr_block, aws_subnet.pub_sub2.cidr_block]
}



resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    "Name" = "${local.env}_VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${local.env}_InternetGateway"
  }
}

resource "aws_subnet" "pub_sub1" {
  cidr_block               = "192.168.1.0/24"
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch  = true
  vpc_id                   = aws_vpc.vpc.id

  tags = {
    "Name" = "${local.env}_PublicSubnet1"
    "kubernetes.io/cluster/${local.env}-eks" = "shared"
  }
}

resource "aws_subnet" "pub_sub2" {
  cidr_block               = "192.168.2.0/24"
  availability_zone        = "us-east-1b"
  map_public_ip_on_launch  = true
  vpc_id                   = aws_vpc.vpc.id

  tags = {
    "Name" = "${local.env}_PublicSubnet2"
    "kubernetes.io/cluster/${local.env}-eks" = "shared"
  }
}

resource "aws_subnet" "priv_sub1" {
  cidr_block        = "192.168.3.0/24"
  availability_zone = "us-east-1c"
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${local.env}_PrivateSubnet1"
    "kubernetes.io/cluster/${local.env}-eks" = "shared"
  }
}

resource "aws_subnet" "priv_sub2" {
  cidr_block        = "192.168.4.0/24"
  availability_zone = "us-east-1d"
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${local.env}_PrivateSubnet2"
    "kubernetes.io/cluster/${local.env}-eks" = "shared"
  }
}

resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${local.env}_PrivateRouteTable"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${local.env}_PublicRouteTable"
  }
}

resource "aws_route_table_association" "pub-sub1-rt-association" {
  route_table_id = aws_route_table.pub_rt.id
  subnet_id      = aws_subnet.pub_sub1.id
}

resource "aws_route_table_association" "pub-sub2-rt-association" {
  route_table_id = aws_route_table.pub_rt.id
  subnet_id      = aws_subnet.pub_sub2.id
}

resource "aws_route_table_association" "priv-sub1-rt-association" {
  route_table_id = aws_route_table.priv_rt.id
  subnet_id      = aws_subnet.priv_sub1.id
}

resource "aws_route_table_association" "priv-sub2-rt-association" {
  route_table_id = aws_route_table.priv_rt.id
  subnet_id      = aws_subnet.priv_sub2.id
}

resource "aws_route" "pub-rt" {
  route_table_id         = aws_route_table.pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
