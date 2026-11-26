
# Caching NFS to S3 file server with JuiceFS v1.4x
**Use a VM only, LXC and FUSE DO NOT WORK**


## JuiceFS install

https://juicefs.com/docs/community/getting-started/standalone

```
sudo curl -sSL https://d.juicefs.com/install | sh -
```

### Format S3 for storage
Create a bucket in S3, pick a name


### Sharktech example for juicefs bucket
```
sudo juicefs format \
    --storage s3 \
    --bucket https://juicefs.s3.lax.sharktech.net \
    --access-key <access-key here> \
    --secret-key <secret key here> \
    sqlite3:///opt/juicefs/myjfs.db \
    juicefs
```

### Backblaze example  
https://www.backblaze.com/docs/cloud-storage-juicefs-integration-with-backblaze-b2  

Bucket endpoint  
s3.us-west-000.backblazeb2.com

```
sudo mkdir -p /opt/juicefs
sudo juicefs format \
  --storage s3 \
  --bucket https://s3.us-west-000.backblazeb2.com/juicehome \
  --access-key <access-key here> \
  --secret-key <secret key here> \
  sqlite3:///opt/juicefs/myjfs.db \
  juicefs
```


### Create systemd.service
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
    --free-space-ratio .5
ExecStop=/bin/fusermount -u /mnt/juicefs
Restart=on-failure

[Install]
WantedBy=remote-fs.target
WantedBy=multi-user.target
```
### Enable and Start the services
```
sudo systemctl enable juicefs.service --now
```

If no errors, check ```/mnt/juicefs``` exists

## NFS Server
```sudo apt install nfs-kernel-server```

### Create NFS exports
Make folders under /mnt/juicefs

```
sudo mkdir -p /mnt/juicefs/foldernamegoeshere
```

update ```/etc/exports```
```
/mnt/juicefs/foldernamegoeshere 192.168.100.0/24(rw,sync,no_subtree_check,fsid=2,no_root_squash)
```

### export NFS mounts
```
sudo exportfs -ra
```

## Restoring
https://juicefs.com/docs/community/metadata_dump_load

### Dump existing juicefs db
```
juicefs dump <sqlite3:///opt/juicefs/myjfs.db>  backup.json
```

### Download latest meta-data dump file from S3
We are using Sharktech for now
- Login to browser (s3.sharktech.net) with S3 ID and Key
- Navigate to Buckets > juicefs > juicefs > meta
- Save file on new server to /tmp (i.e. restore-dump.json)

### Restore from json dump file

Assuming file is restore-dump.json
```
juicefs load sqlite3:///opt/juicefs/myjfs.db restore-dump.json
```
Secret Key is not restored, need to restore it
```
juicefs config --secret-key xxxx sqlite3:///opt/juicefs/myjfs.db
```

### Check the filesystem first
```
juicefs fsck sqlite3:///opt/juicefs/myjfs.db
```
If no errors, proceed


