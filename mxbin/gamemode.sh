#!/usr/bin/env sh
HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = true ]; then
  hyprctl eval '
    hl.config({
      animations = {
        enabled = false,
      },
      decoration = {
        rounding = 0,
        shadow = {
          enabled = false,
        },
        blur = {
          enabled = false,
        },
      },
      general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 1,
      },
    })

    hl.unbind("F1")
    hl.unbind("F2")
    hl.unbind("F3")
    hl.unbind("F4")
    hl.unbind("F5")
    hl.unbind("ALT + W")
    hl.unbind("CTRL + ALT + A")
  '
  exit
fi
hyprctl reload config-only
