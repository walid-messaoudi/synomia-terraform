# Output pour l'ID de l'annuaire Managed Microsoft AD
output "synomia_ad_directory_id" {
  value = aws_directory_service_directory.synomia_ad.id
}