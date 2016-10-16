#!/bin/bash

set -x

## Global variables
targetdisk="$1"
zpool="anaheim"
disk01="/dev/sda"
disk02="/dev/sdb"
disk03="/dev/sdc"
disk04="/dev/sdd"


## Get available device size in blocks for shuf command from blockdev 
upperbound=$(blockdev --report | awk '$7 ~ ""$disk01"$" {print $6}') 
echo "upperbound is $upperbound"
## export the zpool to keep ZFS from self-healing the damage
zpool export "$zpool"
echo "$zpool is exported"
##corrupt the raw disk
#for i in 24 do
targetblock=$(shuf --input-range=1-$upperbound --head-count=1)
        echo "targetblock is $targetblock"
    ## run a loop that chooses a random disk and seeks to a random block,
    ## writing garbage onto it from /dev/urandom
    ## 

## import the zpool
zpool import "$zpool"
echo "$zpool is imported"

## scrub the zpool and display results of corruption
zpool scrub "$zpool"
zpool status -v "$zpool"

exit 0
