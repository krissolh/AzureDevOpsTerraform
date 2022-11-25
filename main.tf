# terraform {
#   required_providers {
#     azurerm = {
#       source = "hashicorp/azurerm"
#       version = "3.0.0"
#     }
#   }
# }

provider "azurerm" {
  # Configuration options  
  features {}  
}


#Storing state file, to persist the file
terraform {
  required_providers{
  azurerm = {
      source = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name     = "tf_rg_blobstore"
    storage_account_name    = "tfstorageaccount"
    container_name          = "tfstate"
    key                     = "terraform.tfstate"
  }  
}

#Defining a variable. The variable gets its value from azure-pipelines.yml. In that file, the variable name needs to be prepended "TF_VAR_"
#Variables could also be defined in its own file.
variable "imagebuild" {
  type        = string
  description = "Latest Image Build"
}


resource "azurerm_resource_group" "tf_test" {
    name = "tfmainrg"
    location = "North Europe"
}

resource "azurerm_container_group" "tfcg_test" {
    name = "weatherapi"
    location = azurerm_resource_group.tf_test.location
    resource_group_name = azurerm_resource_group.tf_test.name

    ip_address_type = "Public"
    dns_name_label = "krissolhweatherapi"
    os_type = "Linux"

    container {
        name = "weatherapi"
        image = "krissolh/weatherapi:${var.imagebuild}" #Using image build variable for referencing which version to use. TF needs to see something change.
        cpu = "1"
        memory = "1"

        ports{
            port = 80
            protocol = "TCP"
        }
    }
}
