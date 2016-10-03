#! /bin/bash

## This script creates a simulated workload on the filesystem by incrementally
## downloading and patching the Linux 3.0.X source tree.
## Usage: ./populate.sh {path to target directory}

#set -x
 
linuxver="3.0"
url=https://www.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
rsyncurl=rsync://rsync.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
targetdir="$1"
patchver=patch-"$linuxver"

pushd "$targetdir"

for current in {0..101}; do
    for incremental in {0..101}; do   
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
