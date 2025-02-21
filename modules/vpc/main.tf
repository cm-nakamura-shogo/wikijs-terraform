variable "project_prefix" {}
variable "allow_ingress_cidr_block" {}

output "subnet_id" {
  value = aws_subnet.public_1a.id
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
}

output "private_security_group_id" {
  value = aws_security_group.private_sg.id
}

// VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.project_prefix
  }
}

// インターネットゲートウェイ作成
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.project_prefix
  }
}

// サブネット作成 (パブリック)
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.project_prefix
  }
}

// ルートテーブル作成とインターネットゲートウェイへのルート追加
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.project_prefix
  }
}

// ルート
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

// サブネットにルートテーブルを関連付け
resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

// セキュリティグループ作成
resource "aws_security_group" "sg" {
  name   = "${var.project_prefix}-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ingress_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// サブネット作成 (private)
resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = var.project_prefix
  }
}

// サブネット作成 (private)
resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = var.project_prefix
  }
}

// セキュリティグループ作成
resource "aws_security_group" "private_sg" {
  name   = "${var.project_prefix}-private-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.public_1a.cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}