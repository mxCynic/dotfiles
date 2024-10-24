#!/bin/bash
# this scritp use to auto update files
cd /home/mx/.dotfiles/

git ls-files --others --exclude-standard | xargs git add
git diff --name-only | xargs git add

git commit -m "$(date +"%Y-%m-%d-%H-%M update")"

git push
