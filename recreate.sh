#! /bin/bash

set -x
alias exit="return"

zpool destroy anaheim
zpool create -f anaheim mirror disk01 disk02 mirror disk03 disk04
zfs create anaheim/data

source ./populate.sh /anaheim/data
source ./workload.sh /anaheim/data
zpool status -v
unalias exit
exit 0
