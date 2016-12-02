#!/bin/bash

#set -o
#set -x
set -e

## wrapper.sh - One-shots the population, workload, and benchmarking scripts.

# Check if this is being run as root
if [ $(id --user) -ne 0 ]
	then
		echo "Aborting: wrapper.sh must be run as root"
		exit
	fi

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
        # Try to mount anaheim in case it exists but is not mounted
        set +e
        zfs mount "$poolanaheim" &> /dev/null
        set -e

        if [ -e "$poolanaheimdir" ]
        then
                echo "Existing zpool present. Destroying with the command \` zpool destroy "$poolanaheim"\`"
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
                echo "Zpool \""$poolanaheim"\" created and mounted at "$poolanaheimdir"."
                zpool create "$poolanaheim" mirror /dev/sda /dev/sdb mirror /dev/sdc /dev/sdd
                echo "Creating dataset called \"data\" inside "$poolanaheim"."
                echo "Creating zpool \""$poolanaheim"\"."
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
        echo "Populating zpool "$poolanaheim", please wait..."
        source "$HOME"/zfsproject/populate.sh -d "$poolanaheimdir"/data > /dev/null
        echo ""$poolanaheim" populated."
}

# workload - Call the workload script
workload()
{
        echo "Running synthetic workload now (this takes a while)..."
        source "$HOME"/zfsproject/workload.sh -d "$poolanaheimdir"/data > /dev/null
        echo "Workload complete."
}

# capturecpu - Call the benchmark script
capturecpu()
{
        # echo "Pretending to run benchmark.sh"
        # Run top in batch mode to write to a file,
        # with a measurement increment of 0.5 seconds
        cpufile="CPU$(date +%Y%m%d_%H%M%S%Z)"
        top -b -d 0.5 > "$cpufile".temp & 
}

# display some information about the storage pools' activity
zstatus()
{
        echo "\n"
        zfs list
        echo "\n"
        zpool list -v
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
capturecpu 
populate
workload
zstatus
grep -F "%Cpu(s):" "$cpufile".temp | cut -c 37-38 > "$cpufile".txt
#rm "$cpufile".temp

exit 0
