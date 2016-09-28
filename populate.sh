#! /bin/bash

## populate.sh - Populates a filesystem with a realistic directory and
## file tree using Linux kernel tarballs from kernel.org

#### Constants

targetdir=$1
url1="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.4.22.tar.xz"
url2="https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-3.18.42.tar.xz"
package1="linux-4.4.22.tar.xz"
package2="linux-3.18.42.tar.xz"

#### Functions

## Download the tarball if it exists.
## Accepts one of the constant variables for the tarball link.
download_tarball()
{
    if [ ! -e  $1 ]
    then
        wget $1
    fi
    return 0
}
# end download_tarball()

## Extract the tarball if it exists
## Accepts one of the variables for the package name
extract_tarball()
{
    if [ -e $1 ]
    then
        tar -xvf $1
    fi
    return 0
}

#### Main logic
if [[ $# -eq 0 ]]
then
        echo "Target directory must be specified as an absolute path (aborting)"
        exit 1
else
    ## Enter the target directory
    pushd $1

    download_tarball $url1

    extract_tarball $package1

    ## Delete the downloaded archive after extracting
    rm -f $package1

    ## Exit the target directory
    popd
fi

exit 0
