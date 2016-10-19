#!/bin/bash
## Usage: ./damage.sh [ZPOOL] [DAMAGE LEVEL{1,2,3}]
set -x

## Global variables
zpool="$1"
damagelevel="$2"
writecount=5
## Available disks
disks=('/dev/sda' '/dev/sdb' '/dev/sdc' '/dev/sdd')

case "$damagelevel" in
        1)
                damagesize=5000
                ;;
        2)
                damagezize=12000
                ;;
        3)
                damagesize=20000
                ;;
esac

## Functions

# Target a random disk for corruption. Accepts the array ${disks}, sets $targetdisk
choose_disk()
{
    local choose_disk_list="$1"
    # Get a random device from ${disks}
    local choose_disk_selection=$((RANDOM % 4 ))
    # Set the global $targetdisk
    targetdisk=${choose_disk_list[choose_disk_selection]}
}

# Selects a random location of the target disk to perform the destructive write
get_diskstats()
{
    # Need to determine the blocksize of the device as an upper bound for the target block
    blocksize=$(blockdev --getbsz "$targetdisk")
    # Get the maximum block number of $targetdisk as an upperbound for $targetblock.
    # Leave headroom for the largest possible write.
    upperbound=$(blockdev --report | awk -v var="$targetdisk$" '$7 ~ var {print $6}') - "$damagesize"
    targetblock=$(shuf --input-range=1-"$upperbound" --head-count=1)
    echo "Target disk is now $targetdisk, target block is now $targetblock"
}

write_damage()
{
    # Skips to the target block on the target disk, then writes
    # a random amount of garbage over it. 
    dd bs="$blocksize" count="$damagesize" skip="$targetblock" if=/dev/urandom of="$targetdisk"1
}

## Main

# export the zpool to keep ZFS from self-healing the damage
zpool export "$zpool"

# Select a target and perform the destructive write
while [ "$writecount" -ge 0 ]; do 
    choose_disk disks
    get_diskstats
    write_damage
    writecount=$((writecount - 1 ))
done

# import the zpool
zpool import "$zpool"

# scrub the zpool and display results of corruption
zpool scrub "$zpool"
zpool status -v "$zpool"
## End Main

exit 0
