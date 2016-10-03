#! /bin/bash

## This script creates a simulated workload on the filesystem by incrementally
## downloading and patching the Linux 3.0.X source tree.
## Usage: ./populate.sh {path to target directory}

set -x
 
linuxver="3.0"
url=https://www.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
rsyncurl=rsync://rsync.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
targetdir=~/testdir/linux
patchver=patch-"$linuxver"

pushd "$targetdir"

for current in {4..101}; do
        ## Use a C-style loop so that a variable can be used/set in the incremental version number
        for (( incremental = current ; incremental <= 101 ; incremental += 1 )); do  
        if curl --head --silent --fail --list-only "$url""$patchver"."$current"-"$incremental".gz
        then
            rsync --no-motd -uP "$rsyncurl""$patchver"."$current"-"$incremental".gz "$targetdir"
            gunzip "$targetdir"/"$patchver"."$current"-"$incremental".gz
            patch -p1 < "$targetdir"/"$patchver"."$current"-"$incremental"
            break
    fi
    done    
done

popd

exit 0
