#!/bin/bash

echo "BEFORE: $BEFORE"
echo "AFTER: $AFTER"
echo "`pwd`"
FILES=$(git diff --name-only $BEFORE..$AFTER | grep ".docx")
echo "Processing...\n$FILES"

for f in $FILES
do
  OUT=$(echo $f | sed 's/sources\//articles\//' | sed 's/.docx/.xml/')
  echo "Converting $f to $OUT-1" 
  /opt/actions/Stylesheets/bin/docxtotei "$f" "$OUT-1"
  echo "Converting $OUT-1 to $OUT-2"
  saxon -s:"$OUT-1" -xsl:xslt/process-tei.xsl -o:"$OUT-2"
  echo "Processing Leiden"
  bin/process-leiden.sh "`pwd`/articles/epidoc"
  echo "Converting $OUT-2 to $OUT"
  saxon -s:"$OUT-2" -xsl:xslt/process-tei-2.xsl -o:"$OUT" "cwd=`pwd`"
  rm "$OUT-1" "$OUT-2"
  rm -rf articles/epidoc
done
