#! /bin/bash

## workload.sh - creates a simulated workload on the filesystem by incrementally
## downloading and patching the Linux kernel 3.0.X source tree.
## Usage: ./populate.sh {path to target directory}

if [ $(id --user) -ne 0 ]
	then
		echo "Aborting: workload.sh must be run as root"
		exit
	fi

set -x
 
#### Global variables
linuxver="3.0"
url=https://www.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
rsyncurl=rsync://rsync.kernel.org/pub/linux/kernel/v"$linuxver"/incr/
targetdir="$1"/linux
patchver=patch-"$linuxver"

#### Functions
checkifpatch()
{
    curl --head --silent --fail --list-only "$url""$patchver"."$current"-"$incremental".gz
    return $?
}

downloadpatch()
{
    rsync --no-motd -uP "$rsyncurl""$patchver"."$current"-"$incremental".gz "$targetdir" 
    return 0
}

## Extracts and patches
applypatch()
{
    gunzip "$targetdir"/"$patchver"."$current"-"$incremental".gz
    patch -p1 < "$targetdir"/"$patchver"."$current"-"$incremental"
    return 0
}

#### Options handling and user interface

#### Main logic
pushd "$targetdir"

# Patches for this version tree run from 3.0.4 to 3.0.101
for current in {4..101}; do
    # Use a C-style loop so that a variable can be used/set in the incremental version number
    for (( incremental = current ; incremental <= 101 ; incremental += 1 )); do  
        # Check if the patch exists without cluttering up stdout
        if checkifpatch
        then
            # Download the patch to the source root, unzip, and patch the tree.
            downloadpatch 
            applypatch
            # Break after patching.
            break
        fi
    done    
done

popd

return 0
