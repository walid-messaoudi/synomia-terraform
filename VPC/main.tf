data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "default_http_outbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = data.aws_security_group.default.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "default_mssql_outbound" {
  type              = "ingress"
  from_port         = 1433
  to_port           = 1433
  protocol          = "tcp"
  security_group_id = data.aws_security_group.default.id
  cidr_blocks       = ["0.0.0.0/0"]
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_subnet" "microsoft_ad_1" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.48.0/22"
  availability_zone = "eu-west-3a"
  tags = {
    Name = var.name_subnet_ad1
  }
}

resource "aws_subnet" "microsoft_ad_2" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.52.0/22"
  availability_zone = "eu-west-3b"
  tags = {
    Name = var.name_subnet_ad2
  }
}

resource "aws_subnet" "fsx_1" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.56.0/22"
  availability_zone = "eu-west-3a"
  tags = {
    Name = var.name_subnet_fsx1
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = data.aws_vpc.default.id
  vpc_endpoint_type = "Interface"
  service_name       = "com.amazonaws.${ var.region }.ecr.dkr"  
  subnet_ids         = [data.aws_subnets.default.ids[0]]
  security_group_ids = [data.aws_security_group.default.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = data.aws_vpc.default.id
  vpc_endpoint_type = "Interface"
  service_name       = "com.amazonaws.${ var.region }.ecr.api"
  subnet_ids         = [data.aws_subnets.default.ids[0]] 
  security_group_ids = [data.aws_security_group.default.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id             = data.aws_vpc.default.id
  vpc_endpoint_type = "Interface"
  service_name       = "com.amazonaws.${ var.region }.logs"
  subnet_ids         = [data.aws_subnets.default.ids[0]]
  security_group_ids = [data.aws_security_group.default.id]

  private_dns_enabled = true
}