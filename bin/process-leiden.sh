#!/bin/bash

if [ -d "$1" ]
then
  for f in `ls $1/*.lplus` 
  do
    curl -s -S --data-urlencode content@$f \
      -d "type=$2" -d 'direction=nonxml2xml' \
      https://libdc3-dev-03.oit.duke.edu/xsugar/ \
      > $1/result.json
      if [ `jq 'has("exception")' $1/result.json` == "true" ]
      then
        echo "XSugar conversion error converting:"
        echo "`cat $f`"
        echo "`jq -r '.exception.cause' $1/result.json` Line `jq '.exception.line' $1/result.json`, column `jq '.exception.column' $1/result.json`."
        exit 1
      fi
      jq -r ".content" $1/result.json > $(echo $f | sed 's/.lplus/.xml/')
    if [ $? -ne 0 ]
    then
      exit 1
    else
      rm $f
      rm $1/result.json
    fi
  done
else
  echo "No Leiden+ files found in $1"
fi