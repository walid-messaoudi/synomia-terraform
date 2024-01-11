output "repository_proxy" {
  description = "Le nom du repository ECR pour le proxy"
  value       = aws_ecr_repository.synomia_proxy.repository_url
}

output "repository_scraper" {
  description = "Le nom du repository ECR pour le scraper"
  value       = aws_ecr_repository.synomia_scraper.repository_url
}