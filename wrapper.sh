#! /bin/bash

set -x
set -e

## wrapper.sh - One-shots the population, workload, and benchmarking scripts.

## Check if this is being run as root
#if [ $(id --user) -ne 0 ]
	#then
	#	echo "Aborting: wrapper.sh must be run as root"
	#	exit
	#fi

#### Global variables
$pool-anaheim="anaheim"
$pool-anaheim-dir="/"$pool-anaheim""

#### Functions

# Displays usage information
usage()
{
        echo "usage: "$0""
}

# Destroy the existing pool at run
zdestroy()
{
        if [ -e "$pool-anaheim-dir" ]
        then
                echo "Existing zpool present. Destroying with the command zpool destroy "$pool-anaheim""
                zpool destroy "$pool-anaheim"
        else
                echo "zpool "$pool-anaheim" not present."
        fi
        return 0
}

# Create the new pool
zcreate()
{
        if [ ! -e "$pool-anaheim-dir" ]
        then
                echo "Creating zpool "$pool-anaheim""
                zpool create "$pool-anaheim" mirror /dev/sda /dev/sdb mirror /dev/sdc /dev/sdd
                echo "Creating dataset called data inside "$pool-anaheim"".
                zfs create "$pool-anaheim"/data
        else
               echo ""$pool-anaheim" already exists. Cannot create an existing zpool."
               return 1
        fi
        return 0
}

# Call the populate script
populate()
{
        source "$HOME"/zfsproject/populate.sh -d "$pool-anaheim-dir"/data
}

# Call the workload script
workload()
{
        source "$HOME"/zfsproject/workload.sh -d "$pool-anaheim-dir"/data
}

# Call the benchmark script
benchmark()
{
        echo "Pretending to run benchmark.sh"
        sleep 1
}


#### Options handling and user interface
while getopts ":h" option
do
        case "$option" in
                h)
                        usage
                        exit 0
                        ;;

                :)
                        echo "something isn't working in the option handling"
                        ;;
                ?)
                        echo "wrapper.sh: unknown option -$OPTARG"
                        usage
                        exit 1
                        ;;
        esac
done

#### Main logic

zdestroy
zcreate
populate
workload
benchmark

## zpool destroy anaheim

#zpool create -f anaheim mirror disk01 disk02 mirror disk03 disk04
# zpool create -f anaheim raidz2 disk01 disk02 disk03 disk04

# zfs create anaheim/data

# source populate.sh /anaheim/data

# source workload.sh /anaheim/data

# zpool status -v

exit 0
