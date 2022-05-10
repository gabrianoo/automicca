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

