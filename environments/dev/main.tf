variable "project_prefix" {}
variable "rds_database" {}
variable "rds_password" {}
variable "rds_user" {}
variable "wikijs_allow_ingress_cidr_block" {}

provider "aws" {
  default_tags {
    tags = {
      project_prefix = var.project_prefix
    }
  }
}

module "vpc" {
  source                   = "../../modules/vpc"
  project_prefix           = var.project_prefix
  allow_ingress_cidr_block = var.wikijs_allow_ingress_cidr_block
}

module "ec2" {
  source                   = "../../modules/ec2"
  project_prefix           = var.project_prefix
  public_subnet_id         = module.vpc.subnet_id
  public_security_group_id = module.vpc.security_group_id
  rds_host                 = module.rds.rds_host
  rds_database             = var.rds_database
  rds_password             = var.rds_password
  rds_user                 = var.rds_user
}

module "rds" {
  source                    = "../../modules/rds"
  project_prefix            = var.project_prefix
  private_subnet_ids        = module.vpc.private_subnet_ids
  private_security_group_id = module.vpc.private_security_group_id
  rds_password              = var.rds_password
  rds_database              = var.rds_database
  rds_user                  = var.rds_user

}
