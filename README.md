# Disclaimer

This repository is a build-up (a fork) on top of [terraform-proxmox-kubespray](https://github.com/bbichero/terraform-proxmox-kubespray) with restructuring to meet a general day-to-day needs for automating all infrastructure tasks. The activities can be creating a Kubernetes HA cluster, upgrading hosts, or bootstrapping a whole environment from scratch.

---
# Getting started

The goal of this repository is to bootstrap the whole infrastructure, automate all the repeated steps, and make the infrastructure work a breath.
In this repository, we mainly used two technologies, Terraform and Ansible.

What is Ansible? [read this](https://www.redhat.com/en/technologies/management/ansible/what-is-ansible).
What is Terraform? [read this](https://www.terraform.io/intro).

---

# Requirements

## Applications

| Application | Last tested version |
|-------------|---------------------|
| Git         | 2.39.3              |
| Ansible     | v2.16.4             |
| Terraform   | v1.7.0              |

## Considerations

1. An up and running proxmox node (or more). Documentation can be found [here](https://www.proxmox.com/en/proxmox-ve/get-started).
2. The SSH key is set up in the Proxmox node default account (root) to avoid working with passwords.
Install ansible locally. Documentation can be found [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
3. Install terraform locally. Documentation can be found [here](https://learn.hashicorp.com/tutorials/terraform/install-cli).
4. Install sshpass locally. If you ar using mac, you can find it on homebrew `brew install hudochenkov/sshpass/sshpass`. If you are using ubuntu, you can install sshpass using `sudo apt-get -y install sshpass
`
5. Install netaddr via pip. `pip3 install netaddr`
6. Install jmespath via pip. `pip3 install jmespath`
7. Internet connection on the client machine to download Kubespray.
8. Internet connection on the Kubernetes nodes to download the Kubernetes binaries.

## Building the inventory

To execute the playbooks in this repository, you must create your inventory file. I made an example one in this repository, depending on the values we are using in this repository. Please change the values to match your custom values. Along the way, I will highlight what to change to match your environment.

1. The inventory supports two formats, `INI` and `YAML`. Below is an example of the inventory file in `YAML` format. I added a complete example in this repository with all the hosts we will use in this project.
2. Rename hosts file name
    ```sh
    mv example.hosts.yaml hosts.yaml    
    ```
3. Change hosts.yaml    
    ```yaml
    all:
      children:
        proxmox:
          hosts:
            YOUR_HOST_NAME:
              ansible_user: root
    ```
4. `YOUR_HOST_NAME:` replace this hostname with your Proxmox node hostname.
5. `ansible_user: root` this is the Proxmox default and only created user. Later we will create another user
6. Rename variable file name
    ```sh
    mv example.varsfile.yml varsfile.yml
    ```
7. Change environment variable values

    ```yml 
      node_name: YOUR_PROXMOX_NODE_NAME
      node_host: YOUR_PROXMOX_NODE_HOST_NAME
      disk_name: YOUR_PROXMOX_STORAGE_NAME
    ```
8. `YOUR_PROXMOX_NODE_NAME:` replace this name with your Proxmox node name.
9. `YOUR_PROXMOX_NODE_HOST_NAME` replace this host name with your Proxmox node host name, example `adam.gability.com` .
10. `YOUR_PROXMOX_STORAGE_NAME` this is the Proxmox storage name that used for storing cloud init files.
    
---

# Bootstrapping

To build up your infrastructure, you will need specific components, whether they are automated or not. This guide isn't designed to follow as is but instead, follow the sections you need to execute. The guide also will give you several workarounds if you want to get started quickly.

## Proxmox

This section is to prepare your Proxmox node(s) to act as a cloud provider for you. This preparation step will ease later provisioning compute instances and customizing the infrastructure to our needs.

### Initializing Proxmox

We will execute our first playbook using the below command, where we provide the playbook's location to run.

This playbook aims to;
1. Remove the PVE enterprise repository from the sources list to avoid failures while executing the OS update and upgrade tasks,
2. Add PVE no subscription repository to the source list,
3. Upgrade all packages if possible,
Upgrade distro if possible,
Finally, remove dependencies that are no longer required.

```bash
ansible-playbook proxmox/init.yaml -i hosts.yaml
```

### Setting up Proxmox pass-through

This playbook aims to;
1. Check whether `iommu` is enabled or not,
2. Enable it if it doesn't exist. Please note that the code here is only for `intel`. If you are using `AMD`, please update the Yaml file `proxmox/iommu.yaml`,
3. Enable vfio modules (`vifo`, `vfio_iommu_type1`, `vfio_pci`, `vfio_virqfd`) if they don't exist,
4. Allow unsafe interrupts for vfio common type1.

```bash
ansible-playbook proxmox/iommu.yaml -i hosts.yaml
```

### Create cloud-init Proxmox template

This step is the base for all our Terraform code later, where we will provision virtual machines using this template.

This step uses the password local store, or you need to replace the local pass store with a hardcoded values. To set up password local store, please visit [Setting up password store section](#setting-up-password-store).

If you set up the local store, please insert the required lookups first before executing the playbook.
```bash
pass insert ci/user
pass insert ci/password
pass insert pve/user
pass insert pve/password
```
Or else please replace `{{ lookup('passwordstore', 'ci/user') }}` with the cloud init username. This username will be used later to log in to the cloud-init virtual machines. Replace `{{ lookup('passwordstore', 'ci/password') }}` with the cloud-init password.
Also replace `{{ lookup('passwordstore', 'pve/user') }}` and `{{ lookup('passwordstore', 'pve/password') }}` with the current username and password for proxmox.

This playbook aims to;
1. Install pip for python 3,
2. Install proxime and TestFlight-tools (to install packages in our cloud init image),
3. Download ubuntu 22.04 Jammy cloud init image,
4. Install `qemu-guest-agent` inside the new cloud init image,
5. Create an empty VM using Cloud-Init,
6. Import and attach Cloud-Init disk,
7. Convert VM to a template. 

```bash
ansible-playbook proxmox/cloudinit.yaml -i hosts.yaml
```

### Create a terraform account

Please insert the required lookups first before executing the playbook.
```bash
pass insert terraform/user # You can use `terraform@pve`
pass insert terraform/password
```
If you didn't set up the local pass store, please replace `{{ lookup('passwordstore', 'terraform/user') }}` and `{{ lookup('passwordstore', 'terraform/password') }}` with the new Terraform Proxmox username and password.

This playbook aims to;
1. Create a new proxmox role named `Terraform` for our terraform user,
2. Create a new proxmox user for our terraform user,
3. Assign the terraform role to the terraform user.

```bash
ansible-playbook proxmox/terraform.yaml -i hosts.yaml
```

## Kubernetes

### Assumptions and Configurations
1. Rename hosts file name
    ```sh
    mv example.terraform.tfvars terraform.tfvars    
    ```
2. `YOUR_PROXMOX_NODE_NAME:` replace this name with your Proxmox node name.
3. `YOUR_PROXMOX_NODE_HOST_NAME` replace this host name with your Proxmox node host name, example `adam.gability.com` .
4. `YOUR_PROXMOX_STORAGE_NAME` this is the Proxmox storage name that used for storing cloud init files.
       
Under each category we will share our assumption and the variable name to change it if needed. For a complete list of supported variables please check `kubernetes/variables.tf` and for changing the configurations that we already used ot assumed please check `kubernetes/terraform.tfvars`.

#### Networking

We have the assumption that your network is `192.168.1.0/24`, and we will give the machines (physical or virtual) IPs within this network. We also assumed that we have a search domain `gability.com`, your gateways IP address is `192.168.1.1`, and you have a DNS server at `192.168.1.2`. Below are the variables you need to change in `terraform.tfvars` to adapt your configurations.

| Variable Name     | Our assumption                                                                                                                                                                                  |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `proxmox_url`     | The Proxmox API url, give the machine IP is `192.168.1.10` the URL should be `https://192.168.1.10:8006/api2/json`.                                                                             |
| `vm_searchdomain` | If you have a local search domain inside your network please add it.                                                                                                                            |
| `vm_gateway`      | Your network gateways. In home networks it is usually the router IP address. So, for `192.168.1.0/24` it is usually `192.168.1.1`                                                               |
| `vm_dns`          | We have the assumption that we have a separate DNS server (ex. a PiHole on `192.168.1.2`. But given the assumption it can be your router IP address `192.168.1.1` or even google dns `8.8.8.8`) |

#### Proxmox

We also have for Proxmox a set of assumptions that you need to modify according to your setup.

| Variable Name  | Our assumption                                                                                                                            |
|----------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `proxmox_user` | The Proxmox user responsible for manging the infrastructure. If you followed the Ansible automated Proxmox setup we used `terraform@pve`. |
| `proxmox_node` | The Proxmox node name used while installing Proxmox. In our case we named it `adam`                                                       |
| `vm_storage`   |                                                                                                                                           |
| `vm_sshkeys`   | I have here my GitHub key. Please change it or I will have access to this machine :-D                                                     |
| `vm_template`  | The Proxmox template name. If you followed the Ansible automated Proxmox template setup we created `ubuntu-cloud-22.04`.                  |


#### Versions

The latest setup I tested personally was Kubernetes `v1.23.7` with kuberspray `v2.19.0` on `flannel` network plugin.

### Installing

There is not much to do here except preparing a cup of coffee and wait for the bootstrapping of the cluster to finish.

```bash
terraform init
terraform plan
terraform apply
```

---

# Going advanced

## Setting up password store

Please make sure that you have a GPG key. If not please generate one.
```bash
gpg --full-generate-key
```
Once you generate it, or if you already have the key, copy the UID to use it in the next step.

Make sure you install [password store](https://www.passwordstore.org/). Then go to your home directory and initialize the password store using the UID (gpg-id) you copied before.

```bash
cd ${HOME}
pass init "GPG ID"
```

## Inserting passwords

Now you can insert passwords in the password store as the below example, and remember that you can also add other values, not only passwords. Later we will retrieve these values from the playbooks later using the ansible lookup plugin.
```bash
pass insert ci/user     # Insert a user under the ci directory in the password store.
pass insert ci/password # Insert a password under the ci directory in the password store.
```
