data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "default-${data.aws_vpc.default.id}"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_db_instance" "database" {
  identifier             = var.db_identifier
  instance_class         = "db.t3.micro"
  engine                 = "sqlserver-ex"
  engine_version         = "15.00.4345.5.v1"
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type           = "gp2"
  publicly_accessible    = true
  availability_zone      = "eu-west-3a"

  db_subnet_group_name   = aws_db_subnet_group.default.name

  vpc_security_group_ids = [data.aws_security_group.default.id]

  username               = var.db_username
  password               = var.db_password

  apply_immediately      = true
  backup_retention_period = 0
  skip_final_snapshot    = true
  license_model          = "license-included"
  
  performance_insights_enabled = false

  parameter_group_name   = "default.sqlserver-ex-15.0"
}