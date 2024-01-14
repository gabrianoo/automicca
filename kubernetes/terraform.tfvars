#===============================================================================
# VMware Proxmox configuration
#===============================================================================

# Proxmox API url
proxmox_url = "https://sun.homelab:8006/api2/json"

# Proxmox username used to deploy the infrastructure #
proxmox_user = "terraform@pve"

# Skip the verification of the vCenter SSL certificate (true/false) #
proxmox_unverified_ssl = "true"

# Proxmox datacenter name where the infrastructure will be deployed #
proxmox_node = "sun"

#===============================================================================
# Global virtual machines parameters
#===============================================================================

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
vm_name_prefix = "mcube"

# The Proxmox network name used by the virtual machines #
vm_network_bridge = "vmbr0"

# The netmask used to configure the network cards of the virtual machines (example: 24)#
vm_netmask = "24"

# The seatch domain used for dns in resolv.conf file
vm_searchdomain = "moustafa.uk"

# The network gateway used by the virtual machines #
vm_gateway = "192.168.0.1"

# The DNS server used by the virtual machines #
vm_dns = "192.168.0.15"

# The sshkey used to connect to vm
vm_sshkeys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBwHO4D9NdmnRYVq84HDdjZCS/2GDbs6HQVLVXMDFRc+lRRVK0PXdoH1lKdHLCLWdZhA4UC0e28WaBudVXMGS9kJnQj2k1ix2Z40QnORm3A4rqVD9V2S9TAFODRP2T43obwkq4568s2L+s+YpdK11r25ZtM5JOSUQyiXm/XwD3dSd38No6eYJQOQ+6KGZP8gbOUZ/TlUx7CN6dbZsGNm/t/CGdnV/5Yv4+Ae1lYldIk8c4HB+q8dEH/4qUfGnZVcTIifYeah8gW2ImFo/RQC9Tp8lGzZnZQY/PuAw1ATTCvtZuE9ifXN72Vl7OCwWGqgWjI2GGxLPKud8t6nSz82/eOtpiiGvDcg/kRZtFQgCDxM2/pZPTzsLitFCL11ae6eZiUCEFME2wSjpxcJZLJnjJgsBBTZLhhGeZ4ey2rDbbHmb1zXHEPE1wyFtfPNRMMNPviUObcj/0fup0Fqabpm4BUTtr4QGr0UtOHJNE/VzVMcoPi1Zc43WUbG5Jd6tGfyk= mostafaalaa@1-Tech-MostafaAlaa.local"

# The Proxmox template the virtual machine are based on #
vm_template = "ubuntu-cloud-22.04"

# Use full clone (true/false)
vm_full_clone = "true"

#===============================================================================
# Master node virtual machines parameters
#===============================================================================

# The number of Thread VM will have, vCPUs = Socket * Cores
vm_master_cores = "2"

# The amount of RAM allocated to the master virtual machines #
vm_master_max_ram = "4096"
vm_master_min_ram = "2048"

# The size disk in GB
vm_master_size = "32G"

# The IP addresses of the master virtual machines. You need to define 3 IPs for the masters #
vm_master_ips = {
  "0" = "192.168.0.25"
}

#===============================================================================
# Worker node virtual machines parameters
#===============================================================================

# The number of Thread VM will have, vCPUs = Socket * Cores
vm_worker_cores = "2"

# The amount of RAM allocated to the worker virtual machines #
vm_worker_max_ram = "4096"
vm_worker_min_ram = "3072"

# The size disk in GB
vm_worker_size = "64G"

# The IP addresses of the master virtual machines. You need to define 1 IP or more for the workers #
vm_worker_ips = {
  "0" = "192.168.0.30"
  "1" = "192.168.0.31"
  "2" = "192.168.0.32"
}

#===============================================================================
# HAProxy load balancer virtual machine parameters
#===============================================================================

# The number of Thread VM will have, vCPUs = Socket * Cores
vm_haproxy_cores = "1"

# The amount of RAM allocated to the load balancer virtual machine #
vm_haproxy_max_ram = "2048"
vm_haproxy_min_ram = "1536"

# The size disk in GB
vm_haproxy_size = "32G"

# The IP address of the load balancer floating VIP #
vm_haproxy_vip = "192.168.0.22"

# The IP address of the load balancer virtual machine #
vm_haproxy_ips = {
  "0" = "192.168.0.23"
  "1" = "192.168.0.24"
}

#===============================================================================
# Kubernetes parameters
#===============================================================================

# The Git repository to clone Kubespray from #
k8s_kubespray_url = "https://github.com/kubernetes-sigs/kubespray.git"

# The version of Kubespray that will be used to deploy Kubernetes #
k8s_kubespray_version = "master"

# The Kubernetes version that will be deployed #
k8s_version = "v1.28.2"

# The overlay network plugin used by the Kubernetes cluster #
k8s_network_plugin = "flannel"

# If you use Weavenet as an overlay network, you need to specify an encryption password #
k8s_weave_encryption_password = ""

# The DNS service used by the Kubernetes cluster (coredns/kubedns) #
k8s_dns_mode = "coredns"