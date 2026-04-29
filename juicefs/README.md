# JuiceFS caching NFS to S3 file server

Currently installed on a VM in proxmox.

IP = 192.168.100.50


# Installation

## JuiceFS install
https://juicefs.com/docs/community/getting-started/standalone

```
curl -sSL https://d.juicefs.com/install | sh -
```

## Format S3 for storage
```
sudo juicefs format \
    --storage s3 \
    --bucket https://juicefs.s3.lax.sharktech.net \
    --access-key <access-key here> \
    --secret-key <secret key here> \
    sqlite3://opt/juicefs/myjfs.db \
    juicefs
```
## Create Mount
Create ```/etc/systemd/system/mnt-juicefs.mount```

```
[Mount]
What=sqlite3://opt/juicefs/myjfs.db
Where=/mnt/juicefs
Type=juicefs
Options=writeback_cache,verbose

[Install]
WantedBy=remote-fs.target
WantedBy=multi-user.target
```

## Start the mount
```
sudo systemctl start mnt-juicefs.mount
```

If no errors, check ```/mnt/juicefs``` exists

## Create NFS exports
Makde two folders under /mnt/juicefs

```
/mnt/juicefs/proxmox
/mnt/juicefs/talos
```

update ```/etc/exports```
```
/mnt/juicefs/proxmox 192.168.100.0/24(rw,sync,no_subtree_check,fsid=1,no_root_squash)
/mnt/juicefs/talos 192.168.100.0/24(rw,sync,no_subtree_check,fsid=1,no_root_squash)
```

## export NFS mounts
```
sudo exportfs -ra
```
