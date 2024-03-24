#===============================================================================
# Locals
#===============================================================================

# Extra args for ansible playbooks #
locals {
  ssh_user = var.vm_ssh_user != null ? var.vm_ssh_user : data.pass_password.ci_user.password
  ssh_password = var.vm_ssh_user_password != null ? var.vm_ssh_user_password : data.pass_password.ci_pass.password

  extra_args = {
    ubuntu = "-T 300"
    debian = "-T 300"
    centos = "-T 300"
    rhel   = "-T 300"
  }
}

#===============================================================================
# Null Resource
#===============================================================================

# Modify the permission on the config directory
resource "null_resource" "config_permission" {
  provisioner "local-exec" {
    command = "chmod -R 700 config"
  }

  depends_on = [
    local_file.haproxy,
    local_file.kubespray_hosts,
    local_file.kubespray_k8s_cluster,
    local_file.kubespray_all,
  ]
}

# Remove the local kubespray folder and clone Kubespray repository #
resource "null_resource" "kubespray_download" {
  provisioner "local-exec" {
    command = "rm -rf kubespray && git clone --branch ${var.k8s_kubespray_version} ${var.k8s_kubespray_url}"
  }
}

# Execute HAProxy Ansible playbook #
resource "null_resource" "haproxy_install" {
  count = var.action == "create" ? 1 : 0

  provisioner "local-exec" {
    command = "cd ../haproxy && ansible-playbook -i ../kubernetes/config/hosts.ini -b -u ${local.ssh_user} -e \"ansible_ssh_pass=${local.ssh_password} ansible_become_pass=${local.ssh_password}\" ${local.extra_args[var.vm_distro]} -v haproxy.yml"
  }

  depends_on = [
    local_file.kubespray_hosts,
    local_file.haproxy,
    proxmox_vm_qemu.haproxy,
  ]
}

# Execute create Kubespray Ansible playbook #
resource "null_resource" "kubespray_create" {
  count = var.action == "create" ? 1 : 0

  provisioner "local-exec" {
    command = "cd kubespray && ansible-playbook -i ../config/hosts.ini -b -u ${local.ssh_user} -e \"ansible_ssh_pass=${local.ssh_password} ansible_become_pass=${local.ssh_password} kube_version=${var.k8s_version}\" ${local.extra_args[var.vm_distro]} -v cluster.yml"
  }

  depends_on = [
    local_file.kubespray_hosts,
    null_resource.kubespray_download,
    local_file.kubespray_all,
    local_file.kubespray_k8s_cluster,
    null_resource.haproxy_install,
    proxmox_vm_qemu.haproxy,
    proxmox_vm_qemu.worker,
    proxmox_vm_qemu.master,
  ]
}

# Execute scale Kubespray Ansible playbook #
resource "null_resource" "kubespray_add" {
  count = var.action == "add_worker" ? 1 : 0

  provisioner "local-exec" {
    command = "cd kubespray && ansible-playbook -i ../config/hosts.ini -b -u ${local.ssh_user} -e \"ansible_ssh_pass=${local.ssh_password} ansible_become_pass=${local.ssh_password} kube_version=${var.k8s_version}\" ${local.extra_args[var.vm_distro]} -v scale.yml"
  }

  depends_on = [
    local_file.kubespray_hosts,
    local_file.kubespray_all,
    local_file.kubespray_k8s_cluster,
    null_resource.haproxy_install,
    proxmox_vm_qemu.haproxy,
    proxmox_vm_qemu.worker,
    proxmox_vm_qemu.master,
  ]
}

# Execute upgrade Kubespray Ansible playbook #
resource "null_resource" "kubespray_upgrade" {
  count = var.action == "upgrade" ? 1 : 0

  triggers = {
    ts = timestamp()
  }

  provisioner "local-exec" {
    command = "cd kubespray && ansible-playbook -i ../config/hosts.ini -b -u ${local.ssh_user} -e \"ansible_ssh_pass=${local.ssh_password} ansible_become_pass=${local.ssh_password} kube_version=${var.k8s_version}\" ${local.extra_args[var.vm_distro]} -v upgrade-cluster.yml"
  }

  depends_on = [
    local_file.kubespray_hosts,
    local_file.kubespray_all,
    local_file.kubespray_k8s_cluster,
    null_resource.haproxy_install,
    proxmox_vm_qemu.haproxy,
    proxmox_vm_qemu.worker,
    proxmox_vm_qemu.master,
  ]
}

# Create the local admin.conf kubectl configuration file #
resource "null_resource" "kubectl_configuration" {
  provisioner "local-exec" {
    command = "ansible -i ${var.vm_master_ips[0]}, -b -u ${local.ssh_user} -e \"ansible_ssh_pass=${local.ssh_password} ansible_become_pass=${local.ssh_password}\" ${local.extra_args[var.vm_distro]} -m fetch -a 'src=/etc/kubernetes/admin.conf dest=config/admin.conf flat=yes' all"
  }

  provisioner "local-exec" {
    command = "sed 's/lb-apiserver.kubernetes.local/${var.vm_haproxy_vip}/g' config/admin.conf | tee config/admin.conf.new && mv config/admin.conf.new config/admin.conf && chmod 700 config/admin.conf"
  }

  provisioner "local-exec" {
    command = "chmod 600 config/admin.conf"
  }

  depends_on = [null_resource.kubespray_create]
}
