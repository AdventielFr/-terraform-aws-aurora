
provider "aws" {
  region = "eu-west-1"
}

locals {
  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  cidr             = "172.16.0.0/16"
  project          = "sample"
  owner            = "dev"
  environment      = "example"
  public_subnets   = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  database_subnets = ["172.16.101.0/24", "172.16.102.0/24", "172.16.103.0/24"]
  tags = {
    Owner       = local.owner
    Environment = local.environment
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.15.0"

  name = "simple-example"

  cidr = local.cidr

  azs              = local.azs
  public_subnets   = local.public_subnets
  database_subnets = local.database_subnets

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true

  tags = local.tags

  vpc_tags = {
    Name = "vpc-simple"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "${local.environment}-all-from-all"
  description = "Enable all ports inbound traffic from all"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [local.cidr]
  }

  tags = {
    Environment = local.environment
  }
}

resource "random_string" "password" {
  keepers = {
    id = "${local.environment}-${local.project}"
  }
  length      = 16
  special     = false
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  min_special = 2
}

module "rds" {
  source                          = "../../"
  engine                          = "aurora-postgresql"
  engine-version                  = "10.7"
  name                            = "${local.environment}-${local.project}-db"
  environment                     = local.environment
  project                         = local.project
  subnets                         = module.vpc.database_subnets
  azs                             = local.azs
  security_groups                 = [aws_security_group.allow_all.id]
  db_subnet_group_name            = module.vpc.database_subnet_group
  instance_type                   = "db.t3.medium"
  username                        = "administrator"
  password                        = random_string.password.result
  final_snapshot_identifier       = "${local.environment}-${local.project}-db-snapshot"
  apply_immediately               = true
  db_parameter_group_name             = aws_db_parameter_group.this.id
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.this.id
  publicly_accessible             = true
  deletion_protection             = false
}


resource "aws_db_parameter_group" "this" {
  name        = "${local.environment}-${local.project}-db-parameter-group"
  family      = "aurora-postgresql10"
  description = "The Aurora db parameters group for ${local.environment} ${local.project}"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${local.environment}-${local.project}-db-cluster-parameter-group"
  family      = "aurora-postgresql10"
  description = "The Aurora db cluster parameters group for ${local.environment} ${local.project}"
  tags        = local.tags
}

