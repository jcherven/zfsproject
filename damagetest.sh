#!/bin/bash
## Usage: ./damage.sh [ZPOOL] [DAMAGE LEVEL{1,2,3}]
set -x

## Global variables
zpool="$1"
damagelevel="$2"
## Available disks
disks=('/dev/sda' '/dev/sdb' '/dev/sdc' '/dev/sdd')

case "$2" in
        1)
                damagedblocks=20
                ;;
        2)
                damagedblocks=10000
                ;;
        3)
                damagedblocks=300000
                ;;
esac

## export the zpool to keep ZFS from self-healing the damage
zpool export "$zpool"

##corrupt the raw disk

# Target a random disk for corruption 
# Get a random element from $disks
disknum=$(($RANDOM % 4))
targetdisk=${disks[disknum]}
# Get the maximum block number of $targetdisk as an upperbound for $targetblock
blocksize=$(blockdev --getbsz $targetdisk)

## Target a random block from $targetdisk for corruption
until [ "$damagedblocks" -le 0 ]; do 
    upperbound=$(blockdev --report | awk -v var="$targetdisk$" '$7 ~ var {print $6}')
    targetblock=$(shuf --input-range=1-$upperbound --head-count=1)
    echo "Target disk is now $targetdisk, target block is now $targetblock"
    damagedblocks=$((damagedblocks - 1 ))
# Seeks to the target block on the target disk, then writes one block of garbage over it
dd bs="$blocksize" count=1 seek="$targetblock" if=/dev/urandom of="$targetdisk"1
done

## import the zpool
zpool import "$zpool"

## scrub the zpool and display results of corruption
zpool scrub "$zpool"
zpool status -v "$zpool"

exit 0
