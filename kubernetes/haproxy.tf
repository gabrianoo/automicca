#===============================================================================
# Proxmox HAProxy Resources
#===============================================================================

# Create the HAProxy load balancer VM #
resource "proxmox_vm_qemu" "haproxy" {
  count       = length(var.vm_haproxy_ips)
  name        = "${var.vm_name_prefix}-haproxy-${count.index}"
  target_node = var.proxmox_node

  clone = var.vm_template
  agent = 1
  tags  = var.vm_tags

  ciuser                  = local.ssh_user
  cipassword              = local.ssh_password
  cloudinit_cdrom_storage = var.vm_storage

  os_type    = "cloud-init"
  sockets    = var.vm_sockets
  cores      = var.vm_haproxy_cores
  vcpus      = var.vm_sockets * var.vm_haproxy_cores
  cpu        = "host"
  numa       = var.vm_numa
  memory     = var.vm_haproxy_max_ram
  balloon    = var.vm_haproxy_min_ram
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
          size      = var.vm_haproxy_size
          storage   = var.vm_storage
          format    = "raw"
          replicate = true
        }
      }
    }
  }

  ipconfig0    = "ip=${var.vm_haproxy_ips[count.index]}/${var.vm_netmask},gw=${var.vm_gateway}"
  searchdomain = var.vm_searchdomain
  nameserver   = var.vm_dns

  sshkeys = var.vm_sshkeys
}
