#! /bin/bash

set -x
 
for minor in {0..10}; do
    if curl --head --silent --fail --list-only https://www.kernel.org/pub/linux/kernel/v3.0/patch-3.0."$minor".gz
    then
         rsync --no-motd -uP rsync://rsync.kernel.org/pub/linux/kernel/v3.0/patch-3.0."$minor".gz ~/testdir
         gunzip ~/testdir/patch-3.0."$minor".gz
    fi
    
done
