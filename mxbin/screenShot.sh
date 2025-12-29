grim -g "$(slurp -o -r -c '#ff0000ff')" - |
	satty --filename - --fullscreen --output-filename ~/Pictures/Screenshot/satty-$(date '+%Y%m%d-%H:%M:%S').png
