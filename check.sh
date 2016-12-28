#!/usr/bin/env bash

for f in *-morphgnt.txt
do
    diff <( awk '{print $1,$2,$3,$5,$6,$7,$8}' $f) <( git show ${1:-master}:$f )
done
