#!/usr/bin/env bash

set -euo pipefail

if ! command -v wl-paste >/dev/null 2>&1; then
    echo "clipboard.sh: wl-paste is required" >&2
    exit 127
fi

if command -v xclip >/dev/null 2>&1; then
    copy_cmd=(xclip -selection clipboard -in)
elif command -v xsel >/dev/null 2>&1; then
    copy_cmd=(xsel --clipboard --input)
else
    echo "clipboard.sh: xclip or xsel is required" >&2
    exit 127
fi

exec wl-paste --type text --no-newline --watch "${copy_cmd[@]}"
