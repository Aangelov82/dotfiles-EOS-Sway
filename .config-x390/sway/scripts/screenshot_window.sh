#!/bin/bash
REGION=$(slurp -b "#00000080" -c "#ffffff" -d -o)
if [ -n "$REGION" ]; then
    grim -g "$REGION" - | swappy -f -
else
    echo "Screenshot cancelled"
fi