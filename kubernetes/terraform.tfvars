#===============================================================================
# VMware Proxmox configuration
#===============================================================================

# Proxmox API url
proxmox_url = "https://192.168.1.10:8006/api2/json"

# Proxmox username used to deploy the infrastructure #
proxmox_user = "terraform@pve"

# Skip the verification of the vCenter SSL certificate (true/false) #
proxmox_unverified_ssl = "true"

# Proxmox datacenter name where the infrastructure will be deployed #
proxmox_node = "adam"

#===============================================================================
# Global virtual machines parameters
#===============================================================================

# Username used to SSH to the virtual machines #
vm_user = "ansible"

# Password set for user vm_user
vm_password = ""

# Multi docker cpu
vm_numa = true

# VM CPU socket numbers
vm_sockets = 2

# The linux distribution used by the virtual machines (ubuntu/debian/centos/rhel) #
vm_distro = "debian"

# Disk type
vm_disk_type = "scsi"

# Storage name
vm_storage = "local-lvm"

# Storage type
vm_storage_type = "lvm"

# The prefix to add to the names of the virtual machines #
vm_name_prefix = "gcube"

# The Proxmox network name used by the virtual machines #
vm_network_bridge = "vmbr0"

# The netmask used to configure the network cards of the virtual machines (example: 24)#
vm_netmask = "24"

# The seatch domain used for dns in resolv.conf file
vm_searchdomain = "gability.com"

# The network gateway used by the virtual machines #
vm_gateway = "192.168.1.1"

# The DNS server used by the virtual machines #
vm_dns = "192.168.1.2"

# User used for ssh connection
vm_ssh_user = "ansible"

# User password
vm_ssh_user_password = "ansible"

# The sshkey used to connect to vm
vm_sshkeys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjCNggxalChf1YS4qWH+NzeG8rDPtcC+yqf0kFiia8oIyU15oHfKq3KoZqOUAgw58WTVO/OC3SS49zLXTnS971pYXimZoygutYueC5jpHdq3dFq2/zRda/XfZEyQMVWhfuKvc3MH49Y3ljYWGNbC90lE4Uvi8xRO7c3eiOBd5myV2cQAw1MKTJHWh6IHT+/voKx0UkJsxBcUI6v1xJtWuH1/+j01E7I8yt2izsLjIDfqbLuC/a+g63dkNKAfBaq37BLQJRGbozEptGWUrqi3QgcCiD8K6h0JT0iKkqWGd4R0yVx8ONwvI3SacPvou+WzQDV3tYq4H5RRXH7EI8vzMn1lGnZYB61HxxSXi8pueYKLWJLPbnih93iLU4oRntN0PrkOq9it8wnU0D7DufyftaUarWU6//IL2H/F++AMDwzHa6gvv0QCIk7lXoO7Sxx3ryebkS8uakNrfauOp9as4h5slF8kOu8pLRKg43gB7eNmcQ180jHi379p6vhe1OjreWxslUtT7e44iCxBQL37iDQd12O9oy90eP/6WQdurrur+Mzs/RbQAX1yHE82CQNLdb6qH11Fx/8ueqp6vaEUlGDPllu0El0kwBAUXEjIpw1pEhmLdXcbF9y16RND12LpgShQ/EyKeGYJry40wysCio6RU8RBdDlz+adbsbNnQSFQ== gabrianoo@github/38548323 # ssh-import-id gh:gabrianoo
EOF

# The Proxmox template the virtual machine are based on #
vm_template = "ubuntu-cloud-22.04"

# Use full clone (true/false)
vm_full_clone = "true"

#===============================================================================
# Master node virtual machines parameters
#===============================================================================

# The number of Thread VM will have, vCPUs = Socket * Cores
vm_master_cores = "1"

# The amount of RAM allocated to the master virtual machines #
vm_master_ram = "2048"

# The size disk in GB
vm_master_size = "20"

# The IP addresses of the master virtual machines. You need to define 3 IPs for the masters #
vm_master_ips = {
  "0" = "192.168.1.103"
  "1" = "192.168.1.104"
  "2" = "192.168.1.105"
}

#===============================================================================
# Worker node virtual machines parameters
#===============================================================================

# The number of Thread VM will have, vCPUs = Socket * Cores
vm_worker_cores = "1"

# The amount of RAM allocated to the worker virtual machines #
vm_worker_ram = "2048"

# The size disk in GB
vm_worker_size = "20"

# The IP addresses of the master virtual machines. You need to define 1 IP or more for the workers #
vm_worker_ips = {
  "0" = "192.168.1.106"
  "1" = "192.168.1.107"
  "2" = "192.168.1.108"
}

#===============================================================================
# HAProxy load balancer virtual machine parameters
#===============================================================================

# The number of Thread VM will have, vCPUs = Socket * Cores
vm_haproxy_cores = "1"

# The amount of RAM allocated to the load balancer virtual machine #
vm_haproxy_ram = "1024"

# The size disk in GB
vm_haproxy_size = "20"

# The IP address of the load balancer floating VIP #
vm_haproxy_vip = "192.168.1.100"

# The IP address of the load balancer virtual machine #
vm_haproxy_ips = {
  "0" = "192.168.1.101"
  "1" = "192.168.1.102"
}

#===============================================================================
# Kubernetes parameters
#===============================================================================

# The Git repository to clone Kubespray from #
k8s_kubespray_url = "https://github.com/kubernetes-sigs/kubespray.git"

# The version of Kubespray that will be used to deploy Kubernetes #
k8s_kubespray_version = "v2.18.1"

# The Kubernetes version that will be deployed #
k8s_version = "v1.22.6"

# The overlay network plugin used by the Kubernetes cluster #
k8s_network_plugin = "flannel"

# If you use Weavenet as an overlay network, you need to specify an encryption password #
k8s_weave_encryption_password = ""

# The DNS service used by the Kubernetes cluster (coredns/kubedns) #
k8s_dns_mode = "coredns"
