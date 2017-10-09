#!/bin/bash
#
# Connect to Bluetooth audio device and change sink accordingly

# variables: list of sinks and MAC address of device
IFS=$'\n'
sinks=( $(pactl list sinks short) )

device=`echo "devices" | bluetoothctl | grep ^Device | cut -f2 -d" "`
device_underscore=`echo $device | sed -e s/:/_/g`

# if not yet connected
if [[ ${#sinks[@]} -eq 1 ]]; then
	# power on bluetooth and connect to device. Executed twice because one does not work for some reason
	echo -e "power on\nconnect $device" | bluetoothctl
	sleep 10
	echo -e "power on\nconnect $device" | bluetoothctl

	sleep 30

	# set default sink and save for later use
	sink=`pactl list sinks short | grep $device_underscore | awk '{print $1}'`
	pactl set-default-sink $sink
	echo "sink=$sink" > audio_sink
else
	# disconnect device when script is run again
	echo -e "disconnect $device\npower off" | bluetoothctl
fi
