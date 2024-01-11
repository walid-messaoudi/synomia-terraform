variable "service_discovery_namespace" {
  type = "string"
  default = "synomia.dev"
}

variable "description" {
  type = "string"
  default = "Namespace for Synomia development environment"
}

variable "dns_name_proxy" {
  type = "string"
  default = "proxy"
}

variable "dns_name_scraper" {
  type = "string"
  default = "scraper"
}

variable "region" {
  type = "string"
  default = "eu-west-3"
}