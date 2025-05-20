# Ansible Proxmox setup

An attempt to prep the proxmox hosts for Ansiblle usage  

## make sure ssh key is added to all proxmox hosts

Use the root login

```
ssh-copy-id root@192.168.100.42
```

## Ansible module reference
https://docs.ansible.com/ansible/latest/collections/community/general/proxmox_kvm_module.html#ansible-collections-community-general-proxmox-kvm-module
https://docs.ansible.com/ansible/latest/collections/community/general/index.html

## Check connectivity
```
eval `ssh-agent`
ssh-add
ansible proxmox -m ping
```

## Playbooks / Roles

### proxmox.yaml
Makes sure each Proxmox host has the necessary libraries installed.  Uses a role of host

