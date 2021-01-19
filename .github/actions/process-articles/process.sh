#!/bin/bash

FILES=$(echo $CHANGED_FILES | grep "sources/*.docx")

for f in $FILES
do
  OUT = $(echo $f | sed 's/\/sources\//\/articles\//' | sed 's/.docx/.xml/')
  docxtotei "$f" "$OUT-1"
  saxon -s:"$OUT-1" -xsl:xslt/process-tei.xsl -o:"$OUT-2"
  bin/process-leiden.sh sources/epidoc
  saxon -s:"$OUT-2" -xsl:xslt/process-tei-2.xsl -o:"$OUT"
  rm "$OUT-1" "$OUT-2"
done
