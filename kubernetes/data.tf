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