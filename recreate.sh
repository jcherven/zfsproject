#! /bin/bash

if [ $(id --user) -ne 0 ]
	then
		echo "Aborting: recreate.sh must be run as root"
		exit
	fi

set -x

zpool destroy anaheim

#zpool create -f anaheim mirror disk01 disk02 mirror disk03 disk04
zpool create -f anaheim raidz2 disk01 disk02 disk03 disk04

zfs create anaheim/data

alias exit=return

source populate.sh /anaheim/data

source workload.sh /anaheim/data

zpool status -v

unalias exit

exit 0
