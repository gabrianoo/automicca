#===============================================================================
# Proxmox K8S Master Resources
#===============================================================================

# Create the Kubernetes master VMs #
resource "proxmox_vm_qemu" "master" {
  count       = length(var.vm_master_ips)
  name        = "${var.vm_name_prefix}-master-${count.index}"
  target_node = var.proxmox_node

  clone = var.vm_template
  agent = 1
  tags  = var.vm_tags

  ciuser = local.ssh_user

  os_type    = "cloud-init"
  sockets    = var.vm_sockets
  cores      = var.vm_master_cores
  vcpus      = var.vm_sockets * var.vm_master_cores
  cpu        = "host"
  memory     = var.vm_master_max_ram
  balloon    = var.vm_master_min_ram
  full_clone = var.vm_full_clone
  onboot     = true
  scsihw     = "virtio-scsi-pci"

  network {
    model  = "virtio"
    bridge = var.vm_network_bridge
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size      = var.vm_master_size
          storage   = var.vm_storage
          format    = "raw"
          replicate = true
        }
      }
    }
  }

  ipconfig0    = "ip=${var.vm_master_ips[count.index]}/${var.vm_netmask},gw=${var.vm_gateway}"
  searchdomain = var.vm_searchdomain
  nameserver   = var.vm_dns

  sshkeys = var.vm_sshkeys

  depends_on = [proxmox_vm_qemu.haproxy]
}