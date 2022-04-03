#vpc
resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.input.app_name}-vpc"
  }
}

#パブリックサブネット
resource "aws_subnet" "public_0" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "${var.input.app_name}-public-subnet-0"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "${var.input.app_name}-public-subnet-1"
  }
}

#インターネットゲートウェイ
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.input.app_name}-internet-gateway"
  }
}

#ルートテーブル
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.input.app_name}-route-table"
  }
}

#ルート
resource "aws_route" "default" {
  route_table_id         = aws_route_table.default.id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}

#ルートテーブルの関連付け
resource "aws_route_table_association" "public_0" {
  subnet_id      = aws_subnet.public_0.id
  route_table_id = aws_route_table.default.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.default.id
}

#プライベートサブネット
resource "aws_subnet" "private_0" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.65.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.input.app_name}-private-subnet-0"
  }
}
resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.66.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.input.app_name}-private-subnet-0"
  }
}
