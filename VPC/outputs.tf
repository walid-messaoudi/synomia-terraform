# Output pour le sous-réseau Microsoft AD 1
output "microsoft_ad_1_subnet_id" {
  value = aws_subnet.microsoft_ad_1.id
}

# Output pour le sous-réseau Microsoft AD 2
output "microsoft_ad_2_subnet_id" {
  value = aws_subnet.microsoft_ad_2.id
}

# Output pour le sous-réseau FSx 1
output "fsx_1_subnet_id" {
  value = aws_subnet.fsx_1.id
}
