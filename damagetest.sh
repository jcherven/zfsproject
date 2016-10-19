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

## Target a random disk for corruption. Accepts the ${disks}, sets $targetdisk
targetdisk()
{
    # Target a random disk for corruption 
    # Get a random element from $disks
    local targetdisk_list="$1"
    local disknum=0
    disknum=$((RANDOM % 4 ))
    targetdisk=${targetdisk_list[disknum]}
}

## export the zpool to keep ZFS from self-healing the damage
zpool export "$zpool"

##corrupt the raw disk
## Target a random block from $targetdisk for corruption
while [ "$writecount" -ge 0 ]; do 
    targetdisk disks

    # Get the maximum block number of $targetdisk as an upperbound for $targetblock
    blocksize=$(blockdev --getbsz "$targetdisk")
    upperbound=$(blockdev --report | awk -v var="$targetdisk$" '$7 ~ var {print $6}')
    targetblock=$(shuf --input-range=1-"$upperbound" --head-count=1)
    echo "Target disk is now $targetdisk, target block is now $targetblock"
    writecount=$((writecount - 1 ))

# Skips to the target block on the target disk, then writes a random amount of garbage over it
dd bs="$blocksize" count="$damagesize" skip="$targetblock" if=/dev/urandom of="$targetdisk"1
done

## import the zpool
zpool import "$zpool"

## scrub the zpool and display results of corruption
zpool scrub "$zpool"
zpool status -v "$zpool"

exit 0
