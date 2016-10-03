#! /bin/bash

set -x
 
linuxver="3.0"
url=https://www.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
rsyncurl=rsync://rsync.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
targetdir=~/testdir/linux/
patchver=patch-"$linuxver"

pushd "$targetdir"

for current in {0..10}; do
    for incremental in {0..10}; do   
        if curl --head --silent --fail --list-only "$url""$patchver"."$current"-"$incremental".gz
        then
            rsync --no-motd -uP "$rsyncurl""$patchver"."$current"-"$incremental".gz "$targetdir"
            gunzip "$patchver"."$current"-"$incremental".gz
            patch -p1 < "$targetdir""$patchver"."$current"-"$incremental"
    fi
    done    
done

popd

exit 0
