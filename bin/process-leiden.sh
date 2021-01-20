#!/bin/bash

echo "Working in `pwd`"
if [ -f "$1" ]
then
  for f in `ls $1/*.lplus` 
  do
  echo "Converting $f"
  curl --data-urlencode content@$f \
    -d 'type=epidoc' -d 'direction=nonxml2xml' \
    https://libdc3-dev-03.oit.duke.edu/xsugar/ \
    | jq -r .content > $(echo $f | sed 's/.lplus/.xml/')
  done
else
  echo "No Leiden+ files found in $1"
fi