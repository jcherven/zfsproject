#!/bin/bash

set -x

## Global variables
zpool="anaheim"

## Available disks
disks=(disk01 disk02 disk03 disk04)

## Get available device size in blocks for shuf command from blockdev 

## export the zpool to keep ZFS from self-healing the damage
zpool export "$zpool"

##corrupt the raw disk

# Pick a random disk to $targetdisk
disknum=$(( $RANDOM % 4 ))
targetdisk=${disks[disknum]}
echo "target disk is $targetdisk"

# Pick a random block to $targetblock
upperbound=$(blockdev --report | awk -v var="$disk01$" '$7 ~ var {print $6}')
targetblock=$(shuf --input-range=1-$upperbound --head-count=1)
echo "targetblock is $targetblock"
    ## run a loop that chooses a random disk and seeks to a random block,
    ## writing garbage onto it from /dev/urandom
    ## 
## import the zpool
zpool import "$zpool"
echo "$zpool is imported"

## scrub the zpool and display results of corruption
##zpool scrub "$zpool"
##zpool status -v "$zpool"

exit 0
