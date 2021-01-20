#!/bin/bash

FILES=$(git diff --name-only $BEFORE..$AFTER | grep ".docx")

for f in $FILES
do
  OUT=$(echo $f | sed 's/sources\//articles\//' | sed 's/.docx/.xml/')
  /opt/Stylesheets/bin/docxtotei "$f" "$OUT-1"
  saxon -s:"$OUT-1" -xsl:xslt/process-tei.xsl -o:"$OUT-2"
  bin/process-leiden.sh "`pwd`/articles/epidoc"
  saxon -s:"$OUT-2" -xsl:xslt/process-tei-2.xsl -o:"$OUT" "cwd=`pwd`"
  rm "$OUT-1" "$OUT-2"
  rm -rf articles/epidoc
done
