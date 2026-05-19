# JuiceFS caching NFS to S3 file server

Currently installed on a VM in proxmox.

IP = 192.168.100.50

# Installation

## VM Requirements
- qemu-guest-agent installed
- nfs-server installed
- /mnt/juicefs-cache is local NVME drive
- no swap partitions
- 2x4 minimum

## JuiceFS install
https://juicefs.com/docs/community/getting-started/standalone

```
curl -sSL https://d.juicefs.com/install | sh -
```
- Create /opt/juicefs
- Create /mnt/juicefs

## Create caching mount points
This should be an NVME or better drive, not associated with the boot disk
```
sudo mkdir /mnt/juicefs-cache
```

**RESTORING** - Follow Restoring section below and skip to Create systemd.Mount

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

## Create systemd.Mount
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
```

If no errors, check ```/mnt/juicefs``` exists

## Create NFS exports
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

## export NFS mounts
```
sudo exportfs -ra
```

# Restoring
https://juicefs.com/docs/community/metadata_dump_load


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
