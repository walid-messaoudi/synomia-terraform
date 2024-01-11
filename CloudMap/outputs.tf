output "namespace_synomia_dev" {
  description = "The ID of the namespace"
  value       = aws_service_discovery_private_dns_namespace.synomia_dev.name
}

output "url_proxy" {
  description = "The ID of the namespace"
  value       = aws_service_discovery_service.proxy.name
}

output "url_scraper" {
  description = "The ID of the namespace"
  value       = aws_service_discovery_service.scraper.name
}

output "proxy_service_discovery_arn" {
  value = aws_service_discovery_service.proxy.arn
}

output "scraper_service_discovery_arn" {
  value = aws_service_discovery_service.scraper.arn
}