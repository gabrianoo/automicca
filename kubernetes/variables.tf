#================================================================================
# Proxmox connection
#================================================================================

variable "proxmox_url" {
  description = "Proxmox API url"
}

variable "proxmox_user" {
  description = "Proxmox user name"
}

variable "proxmox_password" {
  description = "Proxmox password"
  default = null
}

variable "proxmox_unverified_ssl" {
  description = "Is the Proxmox using a self signed certificate (true/false)"
}

variable "proxmox_node" {
  description = "Proxmox node"
}

variable "proxmox_parallel_thread_count" {
  description = "Proxmox parallel thread count"
  default = 2
}

variable "proxmox_debug" {
  description = "Proxmox enable debugging"
  default = false
}

#================================================================================
# Kubernetes infrastructure
#================================================================================

variable "action" {
  description = "Which action have to be done on the cluster (create, add_worker, remove_worker, or upgrade)"
  default     = "create"
}

variable "worker" {
  type        = list(string)
  description = "List of worker IPs to remove"

  default = [""]
}

variable "vm_user" {
  description = "SSH user for the Proxmox virtual machines (CI - Cloud Init)"
  default     = null
}

variable "vm_password" {
  description = "SSH password for the Proxmox virtual machines (CI - Cloud Init)"
  default     = null
}

variable "vm_numa" {
  description = "Multi socket cpu"
}

variable "vm_sockets" {
  description = "VM CPU socket numbers"
}

variable "vm_distro" {
  description = "Linux distribution of the Proxmox virtual machines (ubuntu/centos/debian/rhel)"
}

variable "vm_disk_type" {
  description = "Disk type (scsi, virtio, ..)"
}

variable "vm_storage" {
  description = "Storage name"
}

variable "vm_storage_type" {
  description = "Storage type (lvm,sci)"
}

variable "vm_network_bridge" {
  description = "Network bridge used for the Proxmox virtual machines"
}

variable "vm_template" {
  description = "Template used to create the Proxmox virtual machines (linked clone)"
}

variable "vm_full_clone" {
  description = "Use linked clone to create the Proxmox virtual machines from the template (true/false). If you would like to use the linked clone feature, your template need to have one and only one snapshot"
  default     = "true"
}

variable "k8s_kubespray_url" {
  description = "Kubespray git repository"
  default     = "https://github.com/kubernetes-incubator/kubespray.git"
}

variable "k8s_kubespray_version" {
  description = "Kubespray version"
  default     = "2.23.1"
}

variable "k8s_version" {
  description = "Version of Kubernetes that will be deployed"
  default     = "1.28.4"
}

variable "vm_master_ips" {
  type        = map(string)
  description = "IPs used for the Kubernetes master nodes"
}

variable "vm_worker_ips" {
  type        = map(string)
  description = "IPs used for the Kubernetes worker nodes"
}

variable "vm_haproxy_vip" {
  description = "IP used for the HAProxy floating VIP"
}

variable "vm_haproxy_ips" {
  type        = map(string)
  description = "IP used for two HAProxy virtual machine"
}

variable "vm_netmask" {
  description = "Netmask used for the Kubernetes nodes and HAProxy (example: 24)"
}

variable "vm_searchdomain" {
  description = "Search domain for DNS kuberntes nodes"
}

variable "vm_gateway" {
  description = "Gateway for the Kubernetes nodes"
}

variable "vm_dns" {
  description = "DNS for the Kubernetes nodes"
}

variable "vm_ssh_user" {
  description = "User used for ssh connection"
  default = null
}

variable "vm_ssh_user_password" {
  description = "User password"
  default = null
}

variable "vm_sshkeys" {
  description = "ssh public key present in home directory of ssh_user"
}

variable "k8s_network_plugin" {
  description = "Kubernetes network plugin (calico/canal/flannel/weave/cilium/contiv/kube-router)"
  default     = "flannel"
}

variable "k8s_weave_encryption_password" {
  description = "Weave network encyption password "
  default     = ""
}

variable "k8s_dns_mode" {
  description = "Which DNS to use for the internal Kubernetes cluster name resolution (example: kubedns, coredns, etc.)"
  default     = "coredns"
}

variable "vm_master_cores" {
  description = "Number of CPU Thread (vCPUs = Socket * cores) for the Kubernetes master virtual machines"
}

variable "vm_master_max_ram" {
  description = "The max amount of RAM for the Kubernetes master virtual machine (example: 1024)"
}

variable "vm_master_min_ram" {
  description = "The min amount of RAM for the Kubernetes master virtual machine (example: 1024), if this value is smaller than vm_haproxy_max_ram the ballon feature will be enabled."
}

variable "vm_master_size" {
  description = "Disk size in GB of VM"
}

variable "vm_worker_cores" {
  description = "Number of CPU Thread (vCPUs = Socket * cores) for the Kubernetes worker virtual machines"
}

variable "vm_worker_max_ram" {
  description = "The max amount of RAM for the Kubernetes worker virtual machine (example: 1024)"
}

variable "vm_worker_min_ram" {
  description = "The min amount of RAM for the Kubernetes worker virtual machine (example: 1024), if this value is smaller than vm_haproxy_max_ram the ballon feature will be enabled."
}

variable "vm_worker_size" {
  description = "Disk size in GB of VM"
}

variable "vm_haproxy_cores" {
  description = "Number of CPU Thread (vCPUs = Socket * cores) for the haproxy virtual machines"
}

variable "vm_haproxy_max_ram" {
  description = "The max amount of RAM for the HAProxy virtual machine (example: 1024)"
}

variable "vm_haproxy_min_ram" {
  description = "The min amount of RAM for the HAProxy virtual machine (example: 1024), if this value is smaller than vm_haproxy_max_ram the ballon feature will be enabled."
}

variable "vm_haproxy_size" {
  description = "Disk size in GB of VM"
}

variable "vm_name_prefix" {
  description = "Prefix for the name of the virtual machines and the hostname of the Kubernetes nodes"
}

variable "vm_tags" {
  description = "Prefix for the tags of the virtual machines of the Kubernetes nodes"
  default = "k8s"
}

#================================================================================
# Ansible setting
#================================================================================

variable "ansible_python_interpreter_path" {
  description = "Python path binary used by ansible"
  default     = "/usr/bin/python"
}
