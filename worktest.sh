#! /bin/bash
 
for major in {0..20}; do
    for minor in {0..100}; do
        curl --head --silent --fail --list-only https://www.kernel.org/pub/linux/kernel/v3.0/patch-3."$major"."$minor".gz
    done
done
