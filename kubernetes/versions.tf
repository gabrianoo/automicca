#===============================================================================
# Installing Providers
#===============================================================================
terraform {
  required_version = ">= 0.12"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }
    pass = {
      source  = "camptocamp/pass"
      version = "2.0.0"
    }
  }
}