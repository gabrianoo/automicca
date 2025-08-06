#===============================================================================
# Local Files
#===============================================================================

# Create Kubespray all.yml configuration file from Terraform template #
resource "local_file" "kubespray_all" {
  content  = local.kubespray_all_rendered
  filename = "config/group_vars/all.yml"
}

# Create Kubespray k8s-cluster.yml configuration file from Terraform template #
resource "local_file" "kubespray_k8s_cluster" {
  content  = local.kubespray_k8s_cluster_rendered
  filename = "config/group_vars/k8s-cluster.yml"
}

# Create Kubespray hosts.ini configuration file from Terraform templates #
resource "local_file" "kubespray_hosts" {
  content = "${join("", local.haproxy_hosts_rendered)}${join("", local.kubespray_hosts_master_rendered)}${join("", local.kubespray_hosts_worker_rendered)}\n[haproxy]\n${join("", local.haproxy_hosts_list_rendered)}\n[kube-master]\n${join(
    "",
    local.kubespray_hosts_master_list_rendered,
    )}\n[etcd]\n${join(
    "",
    local.kubespray_hosts_master_list_rendered,
    )}\n[kube-node]\n${join(
    "",
    local.kubespray_hosts_worker_list_rendered,
  )}\n[k8s_cluster:children]\nkube-master\nkube-node"
  filename = "config/hosts.ini"
}

# Create HAProxy configuration from Terraform templates #
resource "local_file" "haproxy" {
  content  = "${local.haproxy_rendered}${join("", local.haproxy_backend_rendered)}"
  filename = "config/haproxy.cfg"
}

# Create Keepalived master configuration from Terraform templates #
resource "local_file" "keepalived_master" {
  content  = local.keepalived_master_rendered
  filename = "config/keepalived-master.cfg"
}

# Create Keepalived slave configuration from Terraform templates #
resource "local_file" "keepalived_slave" {
  content  = local.keepalived_slave_rendered
  filename = "config/keepalived-slave.cfg"
}