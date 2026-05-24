# JuiceFS caching NFS to S3 file server

Currently installed on a VM in proxmox.

IP = 192.168.100.50

# Installation

## LXC Requirements
- un-check Unpriviledged container
- Features: fuse, nfs, nesting
- .conf file needs
    - lxc.apparmor.profile: unconfined
- 2x2048
- 16gb disk
- local

The .conf file on Proxmox looks like this
```
root@prox-nfs:~# cat /etc/pve/lxc/501.conf 
arch: amd64
cores: 2
features: fuse=1,mount=nfs,nesting=1
hostname: cJuice
memory: 2048
net0: name=eth0,bridge=vmbr0,firewall=1,gw=192.168.100.254,hwaddr=BC:24:11:03:F6:D7,ip=192.168.100.50/24,type=veth
onboot: 1
ostype: ubuntu
rootfs: local:501/vm-501-disk-0.raw,mountoptions=discard,size=16G
swap: 512
tags: talos
unprivileged: 0
lxc.apparmor.profile: unconfined
lxc.cgroup.relative: 0
root@prox-nfs:~# 
```

## VM Requirements
- qemu-guest-agent installed
- nfs-server installed
- no swap partitions
- 2x4 minimum

## JuiceFS install
https://juicefs.com/docs/community/getting-started/standalone

```
curl -sSL https://d.juicefs.com/install | sh -
```

**RESTORING** - Follow Restoring section below and skip to Create systemd.Mount

## Format S3 for storage
```
sudo juicefs format \
    --storage s3 \
    --bucket https://juicefs.s3.lax.sharktech.net \
    --access-key <access-key here> \
    --secret-key <secret key here> \
    sqlite3:///opt/juicefs/myjfs.db \
    juicefs
```

## Create systemd.service
```/etc/systemd/system/juicefs.service```

```
[Unit]
Description=JuiceFS FUSE Mount
Before=nfs-server.service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/juicefs mount sqlite3:///opt/juicefs/myjfs.db /mnt/juicefs \
    --writeback \
    --o writeback_cache \
    --debug 
ExecStop=/bin/fusermount -u /mnt/juicefs
Restart=on-failure

[Install]
WantedBy=remote-fs.target
WantedBy=multi-user.target
```
## Enable and Start the services
```
systemctl enable juicefs.service --now
```

<!-- 
```
/usr/local/bin/juicefs mount sqlite3:///opt/juicefs/myjfs.db /mnt/juicefs  --writeback -o writeback_cache --debug -d
``` -->


<!-- ## Create systemd.Mount
Create ```/etc/systemd/system/mnt-juicefs.mount```

```
[Mount]
What=sqlite3://opt/juicefs/myjfs.db
Where=/mnt/juicefs
Type=juicefs
Options=writeback,verbose,cache-dir=/mnt/juicefs-cache

[Install]
WantedBy=remote-fs.target
WantedBy=multi-user.target
```

## Start the mount
```
sudo systemctl start mnt-juicefs.mount
``` -->

If no errors, check ```/mnt/juicefs``` exists

## NFS Server
```apt install nfs-kernel-server```

### Create NFS exports
Make folders under /mnt/juicefs

```
/mnt/juicefs/proxmox
/mnt/juicefs/talos
```

update ```/etc/exports```
```
/mnt/juicefs/proxmox 192.168.100.0/24(rw,sync,no_subtree_check,fsid=1,no_root_squash)
/mnt/juicefs/talos 192.168.100.0/24(rw,sync,no_subtree_check,fsid=2,no_root_squash)
```

### export NFS mounts
```
sudo exportfs -ra
```

# Restoring
https://juicefs.com/docs/community/metadata_dump_load

## Dump existing juicefs db
```
juicefs dump <sqlite3:///opt/juicefs/myjfs.db>  backup.json
```

## Download latest meta-data dump file from S3
We are using Sharktech for now
- Login to browser (s3.sharktech.net) with S3 ID and Key
- Navigate to Buckets > juicefs > juicefs > meta
- Save file on new server to /tmp (i.e. restore-dump.json)

## Restore from json dump file

Assuming file is restore-dump.json
```
juicefs load sqlite3:///opt/juicefs/myjfs.db restore-dump.json
```
Secret Key is not restored, need to restore it
```
juicefs config --secret-key xxxx sqlite3:///opt/juicefs/myjfs.db
```

## Check the filesystem first
```
juicefs fsck sqlite3:///opt/juicefs/myjfs.db
```
If no errors, proceed
