data "aws_vpc" "default" {
  default = true
}

resource "aws_service_discovery_private_dns_namespace" "synomia_dev" {
  name        = var.service_discovery_namespace
  description = var.description

  vpc = data.aws_vpc.default.id
}

resource "aws_service_discovery_service" "proxy" {
  name = var.dns_name_proxy

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.synomia_dev.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = "43200"
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "scraper" {
  name = var.dns_name_scraper

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.synomia_dev.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = "86400"
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
