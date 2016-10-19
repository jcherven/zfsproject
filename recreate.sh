#! /bin/bash

set -x

zpool destroy anaheim
zpool create -f anaheim mirror disk01 disk02 mirror disk03 disk04
zfs create anaheim anaheim/data

source ./populate.sh anaheim && source ./workload.sh /anaheim/data
exit 0
