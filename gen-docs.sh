#!/bin/bash

for dir in $(find . -mindepth 1 -maxdepth 1 -name .git -prune -o -name .bin -prune -o -type d -print); do
    echo "generation docs for [$dir]"
    terraform-docs markdown $dir > $dir/DOC.md
done