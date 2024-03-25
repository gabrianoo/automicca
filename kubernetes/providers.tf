#===============================================================================
# Proxmox Provider
#===============================================================================

provider "proxmox" {
  pm_api_url      = var.proxmox_url
  pm_user         = var.proxmox_user != null ? var.proxmox_user : data.pass_password.terraform_user.password
  pm_password     = var.proxmox_password != null ? var.proxmox_password : data.pass_password.terraform_pass.password
  pm_tls_insecure = var.proxmox_unverified_ssl

  pm_parallel     = var.proxmox_parallel_thread_count
  pm_debug        = var.proxmox_debug
}
