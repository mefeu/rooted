#!/bin/bash
for file in *.unflat; do
    mv "$file" "$(basename "$file" .unflat).json"
done
