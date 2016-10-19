#! /bin/bash

set -x

zpool destroy anaheim
zpool create anaheim mirror disk01 disk02 mirror disk03 disk04
zpool status
exit 0
