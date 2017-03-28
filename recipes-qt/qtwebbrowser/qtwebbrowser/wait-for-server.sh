#!/bin/sh
while true
do
  #check if someone linstens on port 80
  netstat -lnt| grep ":80 " > /dev/null
  if [ $? == 0 ]; then
    break
  fi
  sleep 1
done
$*
