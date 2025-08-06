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

locals {
  # Kubespray all.yml template #
  kubespray_all_rendered = templatefile("templates/kubespray_all.tpl", {
    loadbalancer_apiserver = var.vm_haproxy_vip
    upstream_dns_server = var.vm_dns
  })

  # Kubespray k8s-cluster.yml template #
  kubespray_k8s_cluster_rendered = templatefile("templates/kubespray_k8s_cluster.tpl", {
    kube_version        = var.k8s_version
    kube_network_plugin = var.k8s_network_plugin
    weave_password      = var.k8s_weave_encryption_password
    k8s_dns_mode        = var.k8s_dns_mode
  })

  # HAProxy hostname and ip list template #
  haproxy_hosts_rendered = [
    for i in range(length(var.vm_haproxy_ips)) : templatefile("templates/ansible_hosts.tpl", {
      hostname = "${var.vm_name_prefix}-haproxy-${i}"
      host_ip  = var.vm_haproxy_ips[i]
    })
  ]

  # Kubespray master hostname and ip list template #
  kubespray_hosts_master_rendered = [
    for i in range(length(var.vm_master_ips)) : templatefile("templates/ansible_hosts.tpl", {
      hostname = "${var.vm_name_prefix}-master-${i}"
      host_ip  = var.vm_master_ips[i]
    })
  ]

  # Kubespray worker hostname and ip list template #
  kubespray_hosts_worker_rendered = [
    for i in range(length(var.vm_worker_ips)) : templatefile("templates/ansible_hosts.tpl", {
      hostname = "${var.vm_name_prefix}-worker-${i}"
      host_ip  = var.vm_worker_ips[i]
    })
  ]

  # HAProxy hostname list template #
  haproxy_hosts_list_rendered = [
    for i in range(length(var.vm_haproxy_ips)) : templatefile("templates/ansible_hosts_list.tpl", {
      hostname = "${var.vm_name_prefix}-haproxy-${i}"
    })
  ]

  # Kubespray master hostname list template #
  kubespray_hosts_master_list_rendered = [
    for i in range(length(var.vm_master_ips)) : templatefile("templates/ansible_hosts_list.tpl", {
      hostname = "${var.vm_name_prefix}-master-${i}"
    })
  ]

  # Kubespray worker hostname list template #
  kubespray_hosts_worker_list_rendered = [
    for i in range(length(var.vm_worker_ips)) : templatefile("templates/ansible_hosts_list.tpl", {
      hostname = "${var.vm_name_prefix}-worker-${i}"
    })
  ]

  # HAProxy template #
  haproxy_rendered = templatefile("templates/haproxy.tpl", {
    bind_ip = var.vm_haproxy_vip
  })

  # HAProxy server backend template #
  haproxy_backend_rendered = [
    for i in range(length(var.vm_master_ips)) : templatefile("templates/haproxy_backend.tpl", {
      prefix_server     = var.vm_name_prefix
      backend_server_ip = var.vm_master_ips[i]
      count             = i
    })
  ]

  # Keepalived master template #
  keepalived_master_rendered = templatefile("templates/keepalived_master.tpl", {
    virtual_ip = var.vm_haproxy_vip
  })

  # Keepalived slave template #
  keepalived_slave_rendered = templatefile("templates/keepalived_slave.tpl", {
    virtual_ip = var.vm_haproxy_vip
  })
}