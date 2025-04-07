#!/bin/sh

# ./decrypt-secrets.sh <path to secrets> <path to age key>

# Read age key from file
AGE_KEY=$(cat $1)

files=($(find . -name "*.enc.yaml" -print))
pattern="\\(.*\\)\\.enc.yaml"

for file in "${files[@]}"
do
  filename=$(expr "$file" : "$pattern")
  SOPS_AGE_KEY=$AGE_KEY sops --decrypt  $file > "$filename.yaml"
done
