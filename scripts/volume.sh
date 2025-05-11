#!/usr/bin/env bash

iDIR="$HOME/.config/scripts/icons"

# Get Volume
get_volume() {
	volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')

	if [[ "$volume" -eq "0" ]]; then
		icon="󰝟"  # nf-mdi-volume-off
	elif [[ "$volume" -le 30 ]]; then
		icon="󰖁"  # nf-mdi-volume-low
	elif [[ "$volume" -le 60 ]]; then
		icon="󰖀"  # nf-mdi-volume-medium
	else
		icon="󰕾"  # nf-mdi-volume-high
	fi

	echo "$icon $volume%"
}

# Get icons
get_icon() {
	current=$(get_volume | awk '{print $2}' | sed 's/%//')
	if [[ "$current" -eq "0" ]]; then
		echo "$iDIR/volume-mute.png"
	elif [[ "$current" -le "30" ]]; then
		echo "$iDIR/volume-low.png"
	elif [[ "$current" -le "60" ]]; then
		echo "$iDIR/volume-mid.png"
	else
		echo "$iDIR/volume-high.png"
	fi
}

# Increase Volume
inc_volume() {
	current_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
	# Check if volume is less than 200%
	if (( $(echo "$current_volume < 2.0" | awk '{print ($1 < 2.0)}') )); then
		wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
		# Ensure volume doesn't exceed 200%
		current_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
		if (( $(echo "$current_volume > 2.0" | awk '{print ($1 > 2.0)}') )); then
			wpctl set-volume @DEFAULT_AUDIO_SINK@ 2.0
		fi
		fi
}

# Decrease Volume
dec_volume() {
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
}

# Toggle Mute
toggle_mute() {
    # Check if the audio is muted by looking for the [MUTED] tag
    mute_status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "\[MUTED\]")

    if [ -n "$mute_status" ]; then
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0  # Unmute
    else
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 1   # Mute
    fi
}

# Execute accordingly
case "$1" in
	--get) get_volume ;;
	--inc) inc_volume ;;
	--dec) dec_volume ;;
	--toggle) toggle_mute ;;
	--get-icon) get_icon ;;
	*) get_volume ;;
esac
