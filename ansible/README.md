# Ansible Proxmox setup

An attempt to prep the proxmox hosts for Ansiblle usage  

## make sure ssh key is added to all proxmox hosts

Use the root login

```
ssh-copy-id root@192.168.100.42
```

## Check connectivity
```
eval `ssh-agent`
ssh-add
ansible proxmox -m ping
```
