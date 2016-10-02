#! /bin/bash

set -x
 
url="https://www.kernel.org/pub/linux/kernel/v3.0/"
rsyncurl="rsync://rsync.kernel.org/pub/linux/kernel/v3.0/"
targetdir=~/testdir/
patchver="patch-3.0."

for minor in {0..10}; do
    if curl --head --silent --fail --list-only "$url""$patchver""$minor".gz
    then
        rsync --no-motd -uP "$rsyncurl""$patchver""$minor".gz "$targetdir"
        gunzip ~/testdir/"$patchver""$minor".gz
    fi
    
done

exit 0
