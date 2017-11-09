# Blatand Lyd

These are two scripts I use with my window manager to control audio.

## bluetooth.sh
Used to connect with a bluetooth audio device. The audio device must already be paired and trusted to connect with.
Configure a keybinding for the script in your WM config. There are no options for the script, simply call `bluetooth.sh

## volume.sh
Controls the volume of your currently used audio interface.
Options: `--up` `--down` `--toggle`


## Dependencies
`bash`

`bluez` with bluetoothctl

`pulseaudio` `pulseaudio-bluetooth`

`awk`
