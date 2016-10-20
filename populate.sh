#! /bin/bash

<<<<<<< HEAD
## Check if this is being run as root
if [ $(id --user) -ne 0 ]
        then
		echo "Aborting: populate.sh must be run as root"
		exit
	fi

# set -x
=======
#set -x
>>>>>>> 580c11f878c860034bf7b5c365ce6b8b1ddae0b7

## populate.sh - Populates a filesystem with a realistic directory and
## file tree using Linux kernel tarballs from kernel.org

#### Constants

targetdir=$1
linuxver="3.0.4"
url1=rsync://rsync.kernel.org/pub/linux/kernel/v3.0/linux-"$linuxver".tar.xz
package1=linux-"$linuxver".tar.xz

#### Functions

## Download the tarball if it doesn't exist, skip downloading if it does.
## Accepts the path passed by the user.
download_tarball()
{
    if [ ! -e "$HOME"/"$1" ]
    then
            # hit the rsync daemon, suppress the MOTD, show progress, and skip if the file exists
            rsync --no-motd -uP "$1" "$HOME"
    fi
    return 0
}
# end download_tarball()

## Extract the tarball if it exists
## Accepts the constant variable for the package name
extract_tarball()
{
    if [ -e "$HOME"/"$1" ]
    then
        tar -xvf "$HOME"/"$1" --directory="$targetdir" 
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
    #rm -f "$package1"

    ## Rename the root folder for easier scripting later on
    mv linux-"$linuxver" linux

    ## Exit the target directory
    popd
fi

return 0
