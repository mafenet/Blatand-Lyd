#!/bin/bash
#
# Control volume using the default or bluetooth device

# variables: file with sink of bluetooth device and list of sinks
sink_file=${HOME}/audio_sink

IFS=$'\n'
sinks=( $(pactl list sinks short) )

# if nothing connected use default sink, otherwise sink of bluetooth device
if [[ ${#sinks[@]} -eq 1 ]]; then
	sink=0
else
	source ${sink_file}
fi

# regulate Volume
case "$1" in
	"toggle")
		pactl set-sink-mute $sink toggle;;
	"high")
		pactl set-sink-volume $sink +10%;;
	"low")
		pactl set-sink-volume $sink -10%;;
esac
