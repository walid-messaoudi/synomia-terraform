data "aws_vpc" "default" {
  default = true
}

data "terraform_remote_state" "VPC" {
  backend = "local"

  config = {
    path = "../VPC/terraform.tfstate"
  }
}

resource "aws_directory_service_directory" "synomia_ad" {
  name     = var.ad_name
  password = var.password
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = data.aws_vpc.default.id
    subnet_ids = [data.terraform_remote_state.VPC.outputs.microsoft_ad_1_subnet_id, data.terraform_remote_state.VPC.outputs.microsoft_ad_2_subnet_id]
  }

  tags = {
    Name = var.tag_name
  }
} 
