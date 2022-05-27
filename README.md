# Disclamer

This repository is a build-up (a fork) on top of [terraform-proxmox-kubespray](https://github.com/bbichero/terraform-proxmox-kubespray) with restructuring to meet a general day to day needs for automating all infrastructure tasks. The activities can be creating a Kubernetes HA cluster, upgrading hosts, or bootstrapping a whole environment from scratch.

---
# Getting started


The goal of this repository is to bootstrap the whole infrastructure, automate all the repeated steps, and make the infrastructure work a breath.
In this repository, we mainly used two technologies, Terraform and Ansible.

What is Ansible? [read this](https://www.redhat.com/en/technologies/management/ansible/what-is-ansible).
What is Terraform? [read this](https://www.terraform.io/intro).

---

# Requirements

## Applications

| Applicaiton | Minimum version |
| ----------- | --------------- |
| Git         | 1.8.2.3         |
| Ansible     | v2.6            |
| Terraform   | v0.12           |
| Jinja       | 2.9.6           |
<!-- | Python netaddr | !!           | -->

## Considtations

1. An up and running proxmox node (or more). Documentation can be found [here](https://www.proxmox.com/en/proxmox-ve/get-started).
1. The SSH key is set up in the Proxmox node default account (root) to avoid working with passwords.
1. Install ansible locally. Documentaion can be found [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
1. Install terraform locally. Documentaion can be found [here](https://learn.hashicorp.com/tutorials/terraform/install-cli).
1. Internet connection on the client machine to download Kubespray.
1. Internet connection on the Kubernetes nodes to download the Kubernetes binaries.

## Building the inventory

To execute the playbooks in this repository, you must create your inventory file. I made an example one in this repository, depending on the values we are using in this repository. Please change the values to match your custom values. Along the way, I will highlight what to change to match your environment.

1. The inventory supports two formats, `INI` and `YAML`. Below is an example of the inventory file in `YAML` format. I added a complete example in this repository with all the hosts we will use in this project.
    ```yaml
    all:
      children:
        proxmox:
          hosts:
            adam.pve.gability.com:
              ansible_user: root
    ```
1. `adam.pve.gability.com:` replace this hostname with your Proxmox node hostname.
1. `ansible_user: root` this is the Proxmox default and only created user. Later we will create another user

---

# Bootstrapping

To build up your infrastructure, you will need specific components, whether they are automated or not. This guide isn't designed to follow as is but instead, follow the sections you need to execute. The guide also will give you several workarounds if you want to get started quickly.

## Proxmox

This section is to prepare your Proxmox node(s) to act as a cloud provider for you. This preparation step will ease later provisioning compute instances and customizing the infrastructure to our needs.

### Initializing Proxmox

We will execute our first playbook using the below command, where we provide the playbook's location to run.

This playbook aims to;
1. Remove the PVE enterprise repository from the sources list to avoid failures while executing the OS update and upgrade tasks,
1. Add PVE no subscription repository to the source list,
1. Upgrade all packages if possible,
Upgrade distro if possible,
Finally, remove dependencies that are no longer required.

```bash
ansible-playbook proxmox/init.yaml -i hosts.yaml
```

### Setting up Proxmox passthrough

This playbook aims to;
1. Check whether `iommu` is enabled or not,
1. Enable it if it doesn't exist. Please note that the code here is only for `intel`. If you are using `AMD`, please update the Yaml file `proxmox/iommu.yaml`,
1. Enable vfio modules (`vifo`, `vfio_iommu_type1`, `vfio_pci`, `vfio_virqfd`) if they don't exist,
1. Allow unsafe interrupts for vfio iommu type1.

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
Or else please replace `{{ lookup('passwordstore', 'ci/user') }}` with the cloud init username. This username will be used later to login to the cloud-init virtual machines. Replace `{{ lookup('passwordstore', 'ci/password') }}` with the cloud-init password.
Also replace `{{ lookup('passwordstore', 'pve/user') }}` and `{{ lookup('passwordstore', 'pve/password') }}` with the current username and password for proxmox.

This playbook aims to;
1. Install pip for python 3,
1. Install proxmoxer,
1. Download ubuntu 22.04 Jammy cloud init image,
1. Create an empty VM using Cloud-Init,
1. Import and attach Cloud-Init disk,
1. Convert VM to a template. 

```bash
ansible-playbook proxmox/cloudinit.yaml -i hosts.yaml
```

### Create a terraform account

Please insert the required lookups first before executing the playbook.
```bash
pass insert terraform/user # You can use `terraform@pve`
pass insert terraform/password
```
If you didn't setup the local pass store, please replace `{{ lookup('passwordstore', 'terraform/user') }}` and `{{ lookup('passwordstore', 'terraform/password') }}` with the new Terraform Proxmox username and password.

This playbook aims to;
1. Create a new proxmox role named `Terraform` for our terraform user,
1. Create a new proxmox user for our terraform user,
1. Assign the terraform role to the terraform user.

```bash
ansible-playbook proxmox/terraform.yaml -i hosts.yaml
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
