# Disclamer

This repository is a build-up (a fork) on top of [terraform-proxmox-kubespray](https://github.com/bbichero/terraform-proxmox-kubespray) with restructuring to meet a general day to day needs for automating all infrastructure tasks. The activities can be creating a Kubernetes HA cluster, upgrading hosts, or bootstrapping a whole environment from scratch.

---

# Requirements

## Applications

| Applicaiton | Minimum version |
| ----------- | --------------- |
| Git         | 1.8.2.3         |
| Ansible     | v2.6  |
| Terraform   | v0.12  |
| Jinja       | 2.9.6  |
| Python netaddr | !!  |

## Considtations

1. An up and running proxmox node (or more). Documentation can be found [here](https://www.proxmox.com/en/proxmox-ve/get-started).
1. Install ansible locally. Documentaion can be found [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
1. Install terraform locally. Documentaion can be found [here](https://learn.hashicorp.com/tutorials/terraform/install-cli).
1. Internet connection on the client machine to download Kubespray.
1. Internet connection on the Kubernetes nodes to download the Kubernetes binaries.

# Getting started

Before you do anything, you will need to have Ansible installed on your machine. What is Ansible? [read this](https://www.redhat.com/en/technologies/management/ansible/what-is-ansible).

## Instaling Ansible

You need to ensure `pip` installation on your machine. Installing Ansible is via pip using the below command.
```bash
python -m pip install --user Ansible
```

## Building the inventory

To execute the playbooks in this repository, you must create your inventory file. The default location for the inventory file is at `/etc/ansible/hosts`. We can override this from the command line or ensure that this one exists.

The inventory supports two formats, `INI` and `YAML`. Below is an example of an inventory `INI` file and its `YAML` version.

```ini
[ubuntu]
localhost
foo.example.com
```
```yaml
all:
  children:
    ubuntu:
      children    
        localhost:
        fo.example.com:
```

## Playbook

To execute your first playbook, use the below command, where we provide the playbook's location to run. We are raising the flag for Ansible `--ask-become-pass` or `-K` to ask us for the sudo password since the used playbook uses the `become` keyword to elevate privileges.
```bash
ansible-playbook ubuntu/upgrade.yaml -K
```

---

# Going advanced

## Setting up password store

Please make sure that you have a GPG key, if not please generate one.
```bash
gpg --full-generate-key
```
Once you generate it, or if you already have the key copy the UID to use it in the next step.

Make sure you install [password store](https://www.passwordstore.org/). Then go to your home directory and initialize the password store using the UID (gpg-id) you copied before.

```bash
cd ${HOME}
pass init "GPG ID"
```

## Inserting passwords

Now you can insert passwords in the password store as the below example and remember that you can also add other values not only passwords. Later we will retrive these values from the playbooks later using ansible lookup plugin.
```bash
pass insert ci/user     # Insert a user under the ci directory in the password store.
pass insert ci/password # Insert a password under the ci directory in the password store.
```
