#!/bin/bash

FILES=$(git diff --name-only $BEFORE..$AFTER | grep ".docx")

for f in $FILES
do
  OUT=$(echo $f | sed 's/sources\//articles\//' | sed 's/.docx/.xml/')
  docxtotei "$f" "$OUT-1"
  if [ $? -ne 0 ]
  then
    echo "Failed to convert $f to TEI."
    exit 1
  fi
  saxon -s:"$OUT-1" -xsl:xslt/process-tei.xsl -o:"$OUT-2"
  if [ $? -ne 0 ]
  then
    echo "Failure in first post-processing step of $f."
    exit 1
  fi
  bin/process-leiden.sh "`pwd`/articles/epidoc" epidoc
  if [ $? -ne 0 ]
  then
    echo "Leiden+ conversion failed for $f."
    exit 1
  fi
  bin/process-leiden.sh "`pwd`/articles/translations" translation_epidoc
  if [ $? -ne 0 ]
  then
    echo "Leiden+ conversion failed for $f."
    exit 1
  fi
  saxon -s:"$OUT-2" -xsl:xslt/process-tei-2.xsl -o:"$OUT" "cwd=`pwd`"
  if [ $? -ne 0 ]
  then
    echo "Failed in last processing step of $f."
    exit 1
  fi
  rm "$OUT-1" "$OUT-2"
  rm -rf articles/epidoc
  rm -rf articles/translations
done
