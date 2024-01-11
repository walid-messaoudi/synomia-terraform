data "terraform_remote_state" "VPC" {
  backend = "local"

  config = {
    path = "../VPC/terraform.tfstate"
  }
}

data "terraform_remote_state" "Directory_Service" {
  backend = "local"

  config = {
    path = "../Directory_Service/terraform.tfstate"
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_fsx_windows_file_system" "FSx" {
  active_directory_id = data.terraform_remote_state.Directory_Service.outputs.synomia_ad_directory_id
  storage_capacity    = 32
  deployment_type = "SINGLE_AZ_1"
  subnet_ids          = [data.terraform_remote_state.VPC.outputs.fsx_1_subnet_id]
  throughput_capacity = 8
  tags = {
    Name = var.name_FSx
  }
}