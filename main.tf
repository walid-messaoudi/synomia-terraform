# Il faut ajouter les variables : 
#  - Directory_Service_password, 
#  - db_password 
#  - SmbFileProvider__Password 
#  - et region 
# au moment de l'exécution de Terraform.

module "VPC" {
  source = "./modules/VPC"
}

module "Directory_Service" {
  source     = "./modules/Directory_Service"
  depends_on = [module.VPC]

  password = var.Directory_Service_password
}

module "FSx" {
  source     = "./modules/FSx"
  depends_on = [module.Directory_Service]
}

module "EC2" {
  source     = "./modules/EC2"
  depends_on = [module.FSx]
}

module "ECR" {
  source     = "./modules/ECR"
  depends_on = [module.EC2]
}

module "RDS" {
  source     = "./modules/RDS"
  depends_on = [module.ECR]

  db_password = var.db_password
}

module "CloudMap" {
  source     = "./modules/CloudMap"
  depends_on = [module.RDS]
}

module "ECS" {
  source     = "./modules/ECS"
  depends_on = [module.CloudMap]

  SmbFileProvider__Password = var.SmbFileProvider__Password
}
