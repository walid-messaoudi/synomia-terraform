variable "security_group_name" {
  type = "string"
  default = "synomia_ad_sg"
}

variable "description" {
  type = "string"
  default = "Security group for Synomia AD instance"
}

variable "key_name" {
  type = "string"
  default = "ssh_mangodb"
}

variable "tag_name" {
  type = "string"
  default = "mongodb"
}

variable "region" {
  type = "string"
  default = "eu-west-3"
}