#! /bin/bash

## This script creates a simulated workload on the filesystem by incrementally
## downloading and patching the Linux kernel 3.0.X source tree.
## Usage: ./populate.sh {path to target directory}
## target directory path must not have a trailing slash

if [ $(id --user) -ne 0 ]
	then
		echo "Aborting: workload.sh must be run as root"
		exit
	fi

set -x
 
linuxver="3.0"
url=https://www.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
rsyncurl=rsync://rsync.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
targetdir="$1"/linux
patchver=patch-"$linuxver"

pushd "$targetdir"

# Patches for this version tree run from 3.0.4 to 3.0.101
for current in {4..101}; do
    # Use a C-style loop so that a variable can be used/set in the incremental version number
    for (( incremental = current ; incremental <= 101 ; incremental += 1 )); do  

        # Check if the patch exists without cluttering up stdout
        if curl --head --silent --fail --list-only "$url""$patchver"."$current"-"$incremental".gz
        then
            # Download the patch to the source root, unzip, and patch the tree. Break after patching.
            rsync --no-motd -uP "$rsyncurl""$patchver"."$current"-"$incremental".gz "$targetdir"
            gunzip "$targetdir"/"$patchver"."$current"-"$incremental".gz
            patch -p1 < "$targetdir"/"$patchver"."$current"-"$incremental"
            break
    fi
    done    
done

popd

exit 0
