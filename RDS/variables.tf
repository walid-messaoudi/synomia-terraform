variable "db_identifier" {
  description = "L'identifiant de l'instance de base de données."
  type        = string
  default     = "database-1"
}

variable "db_username" {
  description = "Le nom d'utilisateur pour l'accès à la base de données."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Le mot de passe pour l'accès à la base de données."
  type        = string
  sensitive   = true
  default     = ""
}

variable "region" {
  type    = "string"
  default = "eu-west-3"
}