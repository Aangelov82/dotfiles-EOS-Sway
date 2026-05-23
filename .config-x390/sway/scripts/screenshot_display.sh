#!/bin/bash
# Screenshot the currently focused output (monitor)
FOCUSED_OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true) | .name')
grim -o "$FOCUSED_OUTPUT" - | swappy -f -
