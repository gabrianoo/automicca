#===============================================================================
# Installing Providers
#===============================================================================

terraform {
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

#===============================================================================
# Pass Data
#===============================================================================

data "pass_password" "terraform_user" {
  path = "terraform/user"
}

data "pass_password" "terraform_pass" {
  path = "terraform/password"
}

data "pass_password" "ci_user" {
  path = "ci/user"
}

data "pass_password" "ci_pass" {
  path = "ci/password"
}

#===============================================================================
# Proxmox Provider
#===============================================================================

provider "proxmox" {
  pm_api_url      = var.proxmox_url
  pm_user         = var.proxmox_user != null ? var.proxmox_user : data.pass_password.terraform_user.password
  pm_password     = var.proxmox_password != null ? var.proxmox_password : data.pass_password.terraform_pass.password
  pm_tls_insecure = var.proxmox_unverified_ssl
}

#===============================================================================
# Template files
#===============================================================================

# Kubespray all.yml template #
data "template_file" "kubespray_all" {
  template = file("templates/kubespray_all.tpl")

  vars = {
    loadbalancer_apiserver = var.vm_haproxy_vip
    upstream_dns_server = var.vm_dns
  }
}

# Kubespray k8s-cluster.yml template #
data "template_file" "kubespray_k8s_cluster" {
  template = file("templates/kubespray_k8s_cluster.tpl")

  vars = {
    kube_version        = var.k8s_version
    kube_network_plugin = var.k8s_network_plugin
    weave_password      = var.k8s_weave_encryption_password
    k8s_dns_mode        = var.k8s_dns_mode
  }
}

# HAProxy hostname and ip list template #
data "template_file" "haproxy_hosts" {
  count    = length(var.vm_haproxy_ips)
  template = file("templates/ansible_hosts.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-haproxy-${count.index}"
    host_ip  = var.vm_haproxy_ips[count.index]
  }
}

# Kubespray master hostname and ip list template #
data "template_file" "kubespray_hosts_master" {
  count    = length(var.vm_master_ips)
  template = file("templates/ansible_hosts.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-master-${count.index}"
    host_ip  = var.vm_master_ips[count.index]
  }
}

# Kubespray worker hostname and ip list template #
data "template_file" "kubespray_hosts_worker" {
  count    = length(var.vm_worker_ips)
  template = file("templates/ansible_hosts.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-worker-${count.index}"
    host_ip  = var.vm_worker_ips[count.index]
  }
}

# HAProxy hostname list template #
data "template_file" "haproxy_hosts_list" {
  count    = length(var.vm_haproxy_ips)
  template = file("templates/ansible_hosts_list.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-haproxy-${count.index}"
  }
}

# Kubespray master hostname list template #
data "template_file" "kubespray_hosts_master_list" {
  count    = length(var.vm_master_ips)
  template = file("templates/ansible_hosts_list.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-master-${count.index}"
  }
}

# Kubespray worker hostname list template #
data "template_file" "kubespray_hosts_worker_list" {
  count    = length(var.vm_worker_ips)
  template = file("templates/ansible_hosts_list.tpl")

  vars = {
    hostname = "${var.vm_name_prefix}-worker-${count.index}"
  }
}

# HAProxy template #
data "template_file" "haproxy" {
  template = file("templates/haproxy.tpl")

  vars = {
    bind_ip = var.vm_haproxy_vip
  }
}

# HAProxy server backend template #
data "template_file" "haproxy_backend" {
  count    = length(var.vm_master_ips)
  template = file("templates/haproxy_backend.tpl")

  vars = {
    prefix_server     = var.vm_name_prefix
    backend_server_ip = var.vm_master_ips[count.index]
    count             = count.index
  }
}

# Keepalived master template #
data "template_file" "keepalived_master" {
  template = file("templates/keepalived_master.tpl")

  vars = {
    virtual_ip = var.vm_haproxy_vip
  }
}

# Keepalived slave template #
data "template_file" "keepalived_slave" {
  template = file("templates/keepalived_slave.tpl")

  vars = {
    virtual_ip = var.vm_haproxy_vip
  }
}

#===============================================================================
# Local Files
#===============================================================================

# Create Kubespray all.yml configuration file from Terraform template #
resource "local_file" "kubespray_all" {
  content  = data.template_file.kubespray_all.rendered
  filename = "config/group_vars/all.yml"
}

# Create Kubespray k8s-cluster.yml configuration file from Terraform template #
resource "local_file" "kubespray_k8s_cluster" {
  content  = data.template_file.kubespray_k8s_cluster.rendered
  filename = "config/group_vars/k8s-cluster.yml"
}

# Create Kubespray hosts.ini configuration file from Terraform templates #
resource "local_file" "kubespray_hosts" {
  content = "${join("", data.template_file.haproxy_hosts.*.rendered)}${join("", data.template_file.kubespray_hosts_master.*.rendered)}${join("", data.template_file.kubespray_hosts_worker.*.rendered)}\n[haproxy]\n${join("", data.template_file.haproxy_hosts_list.*.rendered)}\n[kube-master]\n${join(
    "",
    data.template_file.kubespray_hosts_master_list.*.rendered,
    )}\n[etcd]\n${join(
    "",
    data.template_file.kubespray_hosts_master_list.*.rendered,
    )}\n[kube-node]\n${join(
    "",
    data.template_file.kubespray_hosts_worker_list.*.rendered,
  )}\n[k8s-cluster:children]\nkube-master\nkube-node"
  filename = "config/hosts.ini"
}

# Create HAProxy configuration from Terraform templates #
resource "local_file" "haproxy" {
  content  = "${data.template_file.haproxy.rendered}${join("", data.template_file.haproxy_backend.*.rendered)}"
  filename = "config/haproxy.cfg"
}

# Create Keepalived master configuration from Terraform templates #
resource "local_file" "keepalived_master" {
  content  = data.template_file.keepalived_master.rendered
  filename = "config/keepalived-master.cfg"
}

# Create Keepalived slave configuration from Terraform templates #
resource "local_file" "keepalived_slave" {
  content  = data.template_file.keepalived_slave.rendered
  filename = "config/keepalived-slave.cfg"
}

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

# Clone Kubespray repository #

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
    null_resource.kubespray_download,
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
    command = "rm -rf kubespray && git clone --branch ${var.k8s_kubespray_version} ${var.k8s_kubespray_url}"
  }

  provisioner "local-exec" {
    command = "cd kubespray && ansible-playbook -i ../config/hosts.ini -b -u ${local.ssh_user} -e \"ansible_ssh_pass=${local.ssh_password} ansible_become_pass=${local.ssh_password} kube_version=${var.k8s_version}\" ${local.extra_args[var.vm_distro]} -v upgrade-cluster.yml"
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

#===============================================================================
# Proxmox Resources
#===============================================================================

# Create the Kubernetes master VMs #
resource "proxmox_vm_qemu" "master" {
  count       = length(var.vm_master_ips)
  name        = "${var.vm_name_prefix}-master-${count.index}"
  target_node = var.proxmox_node

  clone      = var.vm_template
  agent      = 1
  tags       = var.vm_tags

  ciuser     = local.ssh_user

  os_type    = "cloud-init"
  sockets    = var.vm_sockets
  cores      = var.vm_master_cores
  vcpus      = var.vm_sockets * var.vm_master_cores
  cpu        = "host"
  memory     = var.vm_master_max_ram
  balloon    = var.vm_master_min_ram
  full_clone = var.vm_full_clone
  onboot     = true

  network {
    model    = "virtio"
    bridge   = var.vm_network_bridge
  }

  disk {
    type         = var.vm_disk_type
    size         = var.vm_master_size
    storage      = var.vm_storage
  }

  ipconfig0    = "ip=${var.vm_master_ips[count.index]}/${var.vm_netmask},gw=${var.vm_gateway}"
  searchdomain = var.vm_searchdomain
  nameserver   = var.vm_dns

  sshkeys = var.vm_sshkeys

  depends_on = [proxmox_vm_qemu.haproxy]
}

# Create the Kubernetes worker VMs #
resource "proxmox_vm_qemu" "worker" {
  count       = length(var.vm_worker_ips)
  name        = "${var.vm_name_prefix}-worker-${count.index}"
  target_node = var.proxmox_node

  clone       = var.vm_template
  agent       = 1
  tags        = var.vm_tags

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

  network {
    model  = "virtio"
    bridge = var.vm_network_bridge
  }

  disk {
    type         = var.vm_disk_type
    size         = var.vm_worker_size
    storage      = var.vm_storage
  }

  ipconfig0    = "ip=${var.vm_worker_ips[count.index]}/${var.vm_netmask},gw=${var.vm_gateway}"
  searchdomain = var.vm_searchdomain
  nameserver   = var.vm_dns

  sshkeys = var.vm_sshkeys

  provisioner "local-exec" {
    when    = destroy
    command = "cd kubespray && ansible-playbook -i ../config/hosts.ini -b -u ${self.ciuser} -e \"ansible_ssh_pass=${self.cipassword} ansible_become_pass=${self.cipassword} node=$VM_NAME delete_nodes_confirmation=yes\" -v remove-node.yml"
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

# Create the HAProxy load balancer VM #
resource "proxmox_vm_qemu" "haproxy" {
  count       = length(var.vm_haproxy_ips)
  name        = "${var.vm_name_prefix}-haproxy-${count.index}"
  target_node = var.proxmox_node

  clone		    = var.vm_template
  agent		    = 1
  tags        = var.vm_tags

  ssh_user    = local.ssh_user
  ciuser      = local.ssh_user
  cipassword  = local.ssh_password

  os_type     = "cloud-init"
  sockets     = var.vm_sockets
  cores       = var.vm_haproxy_cores
  vcpus       = var.vm_sockets * var.vm_haproxy_cores
  cpu         = "host"
  memory      = var.vm_haproxy_max_ram
  balloon     = var.vm_haproxy_min_ram
  full_clone  = var.vm_full_clone
  onboot      = true

  network {
    model  = "virtio"
    bridge = var.vm_network_bridge
  }

  disk {
    type         = var.vm_disk_type
    size         = var.vm_haproxy_size
    storage      = var.vm_storage
  }

  ipconfig0    = "ip=${var.vm_haproxy_ips[count.index]}/${var.vm_netmask},gw=${var.vm_gateway}"
  searchdomain = var.vm_searchdomain
  nameserver   = var.vm_dns

  sshkeys = var.vm_sshkeys
}