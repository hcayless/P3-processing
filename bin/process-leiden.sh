#!/bin/bash

if [ -f "$1" ]
then
  for f in `ls $1/*.lplus` 
  do
  curl --data-urlencode content@$f \
    -d 'type=epidoc' -d 'direction=nonxml2xml' \
    http://libdc3-dev-03.oit.duke.edu/xsugar/ \
    | jq -r .content > $(echo $f | sed 's/.lplus/.xml/')
  done
fi