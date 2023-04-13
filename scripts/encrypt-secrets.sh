#!/bin/sh

# Find files ending in "secret.yaml" and store the results in an array
files=($(find $1 -name "*secret.yaml" -print))
pattern="\\(.*\\)\\.yaml"

# Print the file names (without path) in the array using a loop
for file in "${files[@]}"
do
  filename=$(expr "$file" : "$pattern")
  sops --age age1d40qhm7zaxs2xkwzqetdhgju7k8f5ft98uav2we4unqmg684eansa2zcrv --encrypt --encrypted-regex '^(data|stringData)$' --output "$filename.enc.yaml" $file
done
