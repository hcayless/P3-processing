#!/bin/bash

FILES=$(echo $CHANGED_FILES | grep "sources/*.docx")

for f in $FILES
do
  OUT = $(echo $f | sed 's/\/sources\//\/articles\//' | sed 's/.docx/.xml/')
  saxon -s:"$f" -xsl:xslt/process-tei.xsl -o:"$OUT-1"
  bin/process-leiden.sh sources/epidoc
  saxon -s:"$OUT-1" -xsl:xslt/process-tei-2.xsl -o:"$OUT"
  rm "$OUT-1"
done
