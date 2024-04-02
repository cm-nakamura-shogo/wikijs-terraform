variable "project_prefix" {}
variable "private_subnet_ids" {}
variable "private_security_group_id" {}
variable "rds_database" {}
variable "rds_user" {}
variable "rds_password" {}

output "rds_host" {
  value = aws_db_instance.wikijs.address
}

resource "aws_db_subnet_group" "wikijs" {
  name       = var.project_prefix
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_parameter_group" "wikijs" {
  name   = var.project_prefix
  family = "postgres15"
}

resource "aws_db_instance" "wikijs" {
  instance_class         = "db.t3.micro"
  engine                 = "postgres"
  engine_version         = "15.5"
  storage_type           = "gp2"
  allocated_storage      = 20
  db_name                = var.rds_database
  username               = var.rds_user
  password               = var.rds_password
  parameter_group_name   = aws_db_parameter_group.wikijs.name
  identifier             = var.rds_user
  vpc_security_group_ids = [var.private_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.wikijs.name
  skip_final_snapshot    = true
  deletion_protection    = true

  lifecycle {
    prevent_destroy = false
  }
}
