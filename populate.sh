#! /bin/bash

## populate.sh - Populates a filesystem with a realistic directory and
## file tree using Linux kernel tarballs from kernel.org

#set -x
set -e
#set -o

## Check if this is being run as root
if [ $(id --user) -ne 0 ]
        then
		echo "Aborting: populate.sh must be run as root"
		exit
	fi


#### Global variables

linuxver="3.0.4"
url1=rsync://rsync.kernel.org/pub/linux/kernel/v3.0/linux-"$linuxver".tar.xz
package1=linux-"$linuxver".tar.xz

#### Functions

## Download the tarball if it doesn't exist, skip downloading if it does.
## Accepts $targetdir.
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

## Extract the tarball if it exists. Accepts $package1.
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

#### Options handling and user interface

# Displays usage information
usage()
{
	echo "usage: $0 -d /path/to/target"
}

# Process options and arguments. Provide a standard way to get usage help.
while getopts ":hd:" option
do
	case "$option" in
		d)
			targetdir="$OPTARG"
			;;
		h)
			usage
			exit 0
			;;
		:)
			echo "target dierectory for -$OPTARG must be specified"
			;;
		?)
			echo "populate.sh: unknown option -$OPTARG"
			usage
			exit 1
			;;
		esac
done

## Eliminate any trailing slashes in the target argument
targetdir="${targetdir%/}"

if [ -z "$targetdir" ]
then
	echo "populate.sh: specify a target directory with -d"
	usage
	exit 1
fi

if [ ! -d "$targetdir" ]
then
	echo "populate.sh: -d must be a directory and it must already exist"
	exit 1
fi

#### Main logic
# Enter the target directory
pushd "$targetdir"

download_tarball "$url1"

extract_tarball "$package1"

## Rename the root folder for easier scripting later on
mv linux-"$linuxver" linux

## Exit the target directory
popd

return 0
