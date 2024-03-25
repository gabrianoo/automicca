#===============================================================================
# Installing Providers
#===============================================================================
terraform {
  required_version = ">= 0.12"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
    pass = {
      source  = "camptocamp/pass"
      version = "2.0.0"
    }
  }
}