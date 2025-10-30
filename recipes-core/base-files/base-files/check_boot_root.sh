#!/bin/sh
# arg1: name of device with partiton ending with p1, e.g. mmcblk0p1
# return succss if device with partition 2 is root in cmdline e.g. mmcblk0p2

root=/dev/${1%p1}p2 # remove p1 from arg1 and replace it by p2
grep -q root=${root} /proc/cmdline
