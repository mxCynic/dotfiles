#!/bin/bash
while true; do
  wl-paste | sed -z '$ s/\n$//' | xclip -selection clipboard
  sleep 0.5
done
