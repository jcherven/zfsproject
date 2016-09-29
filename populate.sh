#! /bin/bash

## populate.sh - Populates a filesystem with a realistic directory and
## file tree using Linux kernel tarballs from kernel.org

#### Constants

targetdir=$1
url1="rsync://rsync.kernel.org/pub/linux/kernel/v4.x/linux-4.7.tar.xz"
#url2="rsync://rsync.kernel.org/pub/linux/kernel/v3.x/linux-3.19.tar.xz"
package1="linux-4.7.tar.xz"
#package2="linux-3.19.tar.xz"

#### Functions

## Download the tarball if it doesn't exist, skip downloading if it does.
## Accepts one of the constant variables for the tarball link.
download_tarball()
{
    if [ ! -e "$1" ]
    then
            # hit the rsync daemon, suppress the MOTD, show progress, and skip if the file exists
            rsync --no-motd -uP "$1" "$(pwd)"
    fi
    return 0
}
# end download_tarball()

## Extract the tarball if it exists
## Accepts one of the variables for the package name
extract_tarball()
{
    if [ -e "$1" ]
    then
        tar -xvf "$1"
    else
        echo "Could not extract, archive did not download properly (aborting)"
        return 1
    fi
    return 0
}

#### Main logic
if [[ $# -eq 0 ]]
then
        echo "Target directory must be specified (aborting)"
        exit 1
else
    ## Enter the target directory
    pushd "$targetdir"

    download_tarball "$url1"

    extract_tarball "$package1"

    ## Delete the downloaded archive after extracting
    rm -f "$package1"

    ## Exit the target directory
    popd
fi

exit 0
