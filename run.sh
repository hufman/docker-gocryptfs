#!/bin/sh
set -e

# Expects initialised gocryptfs cipherdir(s) within /crypts at locations specified in:
#       /etc/gocryptfs/crypts
# Decrypts and mounts them in symmetric locations within /mnt
[ -e /etc/gocryptfs ] || mkdir /etc/gocryptfs
[ -e /etc/gocryptfs/crypts ] || ls -d /crypts/* > /etc/gocryptfs/crypts

sed s/crypts/mnt/g /etc/gocryptfs/crypts \
    | tee /etc/gocryptfs/mounts \
    | xargs mkdir -p

# line-buffer: since we're long-running in the foreground, we want each
#   gocryptfs job's output without waiting for the first to finish.
paste /etc/gocryptfs/crypts /etc/gocryptfs/mounts \
    | parallel --colsep='\t' --line-buffer "gocryptfs -allow_other -extpass 'printenv GOCRYPTFS_PSWD' -fg -nosyslog '{1}' '{2}'"
