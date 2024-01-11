variable "Directory_Service_password" {
  description = "Le mot de passe pour Active Directory"
  type        = string
  sensitive   = true
}

variable "SmbFileProvider__Password" {
  description = "Le mot de passe pour SmbFileProvider."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Le mot de passe pour l'accès à la base de données SQL Server."
  type        = string
  sensitive   = true
}

variable "region" {
  type        = string
  default     = "eu-west-3"
}