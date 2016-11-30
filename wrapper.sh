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
poolanaheim="anaheim"
poolanaheimdir="/"$poolanaheim""

#### Functions

# Displays usage information
usage()
{
        echo "usage: "$0""
}

# zdestroy - Destroy the existing pool at run
zdestroy()
{
        if [ -e "$poolanaheimdir" ]
        then
                echo "Existing zpool present. Destroying with the command zpool destroy "$poolanaheim""
                zpool destroy "$poolanaheim"
        else
                echo "zpool "$poolanaheim" not present."
        fi
        return 0
}

# zcreate - Create the new pool
zcreate()
{
        if [ ! -e "$poolanaheimdir" ]
        then
                echo "Creating zpool "$poolanaheim""
                zpool create "$poolanaheim" mirror /dev/sda /dev/sdb mirror /dev/sdc /dev/sdd
                echo "Creating dataset called data inside "$poolanaheim"".
                zfs create "$poolanaheim"/data
        else
               echo ""$poolanaheim" already exists. Cannot create an existing zpool."
               return 1
        fi
        return 0
}

# populate - Call the populate script
populate()
{
        source "$HOME"/zfsproject/populate.sh -d "$poolanaheimdir"/data
}

# workload - Call the workload script
workload()
{
        source "$HOME"/zfsproject/workload.sh -d "$poolanaheimdir"/data
}

# benchmark - Call the benchmark script
benchmark()
{
        # echo "Pretending to run benchmark.sh"
        # Run top in batch mode to write to a file,
        # with a measurement delay of 0.5 seconds
        top -b -d 0.5 > "$HOME"/$(date +%Y%m%d_%H%M%S%Z).txt &
}

#### Options handling and user interface
while getopts ":h" option
do
        case "$option" in
                h)
                        usage
                        exit 0
                        ;;
                #:)
                #        echo "something isn't working in the option handling"
                #        ;;
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
#benchmark 
populate
wait
workload
wait

## zpool destroy anaheim

#zpool create -f anaheim mirror disk01 disk02 mirror disk03 disk04
# zpool create -f anaheim raidz2 disk01 disk02 disk03 disk04

# zfs create anaheim/data

# source populate.sh /anaheim/data

# source workload.sh /anaheim/data

# zpool status -v

exit 0
