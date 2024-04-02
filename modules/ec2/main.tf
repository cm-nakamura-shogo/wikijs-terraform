variable "project_prefix" {}
variable "public_subnet_id" {}
variable "public_security_group_id" {}
variable "rds_host" {}
variable "rds_database" {}
variable "rds_user" {}
variable "rds_password" {}

output "config_content" {
  value = local.config_content
}

output "user_data" {
  value = aws_instance.main.user_data_base64
}

# 信頼ポリシー
data "aws_iam_policy_document" "ec2" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAMロール
resource "aws_iam_role" "role" {
  name               = "${var.project_prefix}-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

# インスタンスプロファイル
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.project_prefix}-instance-role-profile"
  role = aws_iam_role.role.name
}

data "local_file" "config_file" {
  filename = "${path.module}/config.yml"
}

locals {
  config_content = data.local_file.config_file.content
}

# EC2インスタンス
resource "aws_instance" "main" {
  ami                         = "ami-031134f7a79b6e424"
  instance_type               = "t3.small"
  subnet_id                   = var.public_subnet_id
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  vpc_security_group_ids      = [var.public_security_group_id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash

              # nodeのインストール
              yum install nodejs npm -y

              # wikijsのインストール
              mkdir -p /opt/wikijs
              cd /opt/wikijs
              wget https://github.com/Requarks/wiki/releases/latest/download/wiki-js.tar.gz
              mkdir wiki
              tar xzf wiki-js.tar.gz -C ./wiki
              cd ./wiki

              # RDSの証明書バンドルの取得
              wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem

              # configファイルを実体化
              echo "${local.config_content}" > config.yml

              # 環境変数
              export DB_TYPE="postgres"
              export DB_HOST="${var.rds_host}"
              export DB_NAME="${var.rds_database}"
              export DB_PORT=5432
              export DB_USER="${var.rds_user}"
              export DB_PASS="${var.rds_password}"

              # logrotateの設定
              mkdir -p /var/log/wikijs/
              echo "/var/log/wikijs/*.txt {
                daily
                rotate 7
                compress
                delaycompress
                missingok
                notifempty
                create 640 root adm
              }" >/etc/logrotate.d/wikijs

              # wikijsの起動
              node server 2>&1 | tee /var/log/wikijs/log.txt &

              EOF

  tags = {
    Name = "${var.project_prefix}"
  }
}

