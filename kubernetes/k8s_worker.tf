#===============================================================================
# Proxmox K8S Worker Resources
#===============================================================================

# Create the Kubernetes worker VMs #
resource "proxmox_vm_qemu" "worker" {
  count       = length(var.vm_worker_ips)
  name        = "${var.vm_name_prefix}-worker-${count.index}"
  target_node = var.proxmox_node

  clone = var.vm_template
  agent = 1
  tags  = var.vm_tags

  ciuser     = var.vm_ssh_user != null ? var.vm_ssh_user : data.pass_password.ci_user.password
  cipassword = var.vm_ssh_user_password != null ? var.vm_ssh_user_password : data.pass_password.ci_pass.password

  os_type    = "cloud-init"
  sockets    = var.vm_sockets
  cores      = var.vm_worker_cores
  vcpus      = var.vm_sockets * var.vm_worker_cores
  cpu        = "host"
  memory     = var.vm_worker_max_ram
  balloon    = var.vm_worker_min_ram
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
          size      = var.vm_worker_size
          storage   = var.vm_storage
          format    = "raw"
          replicate = true
        }
      }
    }
  }

  ipconfig0    = "ip=${var.vm_worker_ips[count.index]}/${var.vm_netmask},gw=${var.vm_gateway}"
  searchdomain = var.vm_searchdomain
  nameserver   = var.vm_dns

  sshkeys = var.vm_sshkeys

  provisioner "local-exec" {
    when       = destroy
    command    = "cd kubespray && ansible-playbook -i ../config/hosts.ini -b -u ${self.ciuser} -e \"ansible_ssh_pass=${self.cipassword} ansible_become_pass=${self.cipassword} node=$VM_NAME delete_nodes_confirmation=yes\" -v remove-node.yml"
    on_failure = continue
  }

  #provisioner "local-exec" {
  #  when    = destroy
  #  command = "sed 's/${var.vm_name_prefix}-worker-[0-9]*$//' config/hosts.ini"
  #}

  depends_on = [
    proxmox_vm_qemu.master,
    local_file.kubespray_hosts,
    local_file.kubespray_k8s_cluster,
    local_file.kubespray_all,
  ]
}