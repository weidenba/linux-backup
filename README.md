# linux-backup
Scripts to automatically backup Linux Systems

## net_backup.sh

This script has the following functionality:

* boot the backup server via Wake-On-LAN
* mount an encrypted partition on the backup server (The password is not stored on the backup server!)
* one way sync (host -> backup server)
  * choose what to backup
  * exclude non interesting files or folders
* unmount backup partition
* shutdown the backup server

The script aborts if the server is not reachable or if the backup partition is not mounted successfully.

