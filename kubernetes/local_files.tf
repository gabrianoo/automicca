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