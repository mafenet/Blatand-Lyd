#!/bin/bash
#
# Control Brightness with brightnessctl

# variables: brightness and file to save it for later
brightness_file=${HOME}/brightness
brightness=`brightnessctl i | grep Current | cut -d" " -f 3`

# get the previous brightness
source ${brightness_file}

# regulate brightness
case "$1" in
	"toggle")
		if [[ $brightness -gt 0 ]]; then
			brightnessctl s 0
		else
			brightnessctl s $old
		fi
		;;
	"high")
		if [[ $brightness -eq 0 ]]; then	
			brightnessctl s `expr $old + 94`
		else		
	       		 brightnessctl s +10%	
		fi
		;;
	"low")
	        brightnessctl s 10%-	
		;;
esac

# save previous brightness to file
echo "old=${brightness}" > ${brightness_file} 
