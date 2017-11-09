#!/bin/bash
#
# Control volume using the default or bluetooth device

cmd=$1
delta=5
active_sink=$(pacmd list-sinks | awk '/* index:/{print $3}')

# regulate Volume
case "$cmd" in
	--toggle)
		pactl set-sink-mute $active_sink toggle;;
	--up)
		pactl set-sink-volume $active_sink +$delta%;;
	--down)
		pactl set-sink-volume $active_sink -delta%;;
esac
