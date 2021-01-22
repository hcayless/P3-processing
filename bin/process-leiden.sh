#!/bin/bash

if [ -d "$1" ]
then
  for f in `ls $1/*.lplus` 
  do
    curl --data-urlencode content@$f \
      -d 'type=epidoc' -d 'direction=nonxml2xml' \
      https://libdc3-dev-03.oit.duke.edu/xsugar/ \
      | jq -r .content > $(echo $f | sed 's/.lplus/.xml/')
    if [ $? -eq 0 ]
    then
      exit 1
    fi
  done
else
  echo "No Leiden+ files found in $1"
fi