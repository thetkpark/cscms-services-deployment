#!/bin/sh

# Find files ending in "secret.yaml" and store the results in an array
files=($(find $1 -name "*secret.yaml" -print))
pattern="\\(.*\\)\\.yaml"

# Print the file names (without path) in the array using a loop
for file in "${files[@]}"
do
  filename=$(expr "$file" : "$pattern")
  kubeseal -f $file -w "$filename.sealed.yaml"
done
