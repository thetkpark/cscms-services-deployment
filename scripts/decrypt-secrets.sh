#!/bin/sh

# ./decrypt-secrets.sh <path to secrets> <path to age key>

# Read age key from file
AGE_KEY=$(cat $2)
# Find files ending in "secret.enc.yaml" and store the results in an array
files=($(find $1 -name "*secret.enc.yaml" -print))
pattern="\\(.*\\)\\.enc\\.yaml"

# Print the file names (without path) in the array using a loop
for file in "${files[@]}"
do
  filename=$(expr "$file" : "$pattern")
  SOPS_AGE_KEY=$AGE_KEY sops --decrypt  $file > "$filename.test.yaml"
done
