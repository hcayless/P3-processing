#!/bin/bash

FILES=$(git diff --name-only $BEFORE..$AFTER | grep ".docx")

for f in $FILES
do
  NAME=$(echo $f | sed 's/.*\/\([^\/]*\).docx/\1/')
  OUT="$(echo $f | sed 's/sources\//articles\//' | sed 's/.docx/\//')/$NAME.xml"
  # docxtotei "$f" "$OUT-1"
  /opt/actions/Stylesheets/bin/docxtotei "$f" "$OUT-1"
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
  bin/process-leiden.sh "`pwd`/articles/$NAME/epidoc" epidoc
  if [ $? -ne 0 ]
  then
    echo "Leiden+ conversion failed for $f."
    exit 1
  fi
  bin/process-leiden.sh "`pwd`/articles/$NAME/translations" translation_epidoc
  if [ $? -ne 0 ]
  then
    echo "Leiden+ conversion failed for $f."
    exit 1
  fi
  saxon -s:"$OUT-2" -xsl:xslt/process-tei-2.xsl -o:"$OUT" "cwd=`pwd`" "name=$NAME"
  if [ $? -ne 0 ]
  then
    echo "Failed in last processing step of $f."
    exit 1
  fi
  rm "$OUT-1" "$OUT-2"
  rm -rf "articles/$NAME/epidoc"
  rm -rf "articles/$NAME/translations"
done
