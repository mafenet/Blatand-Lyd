# configs

These are my configuration files and scripts I use with my i3 / sway desktop.

## wal.edit.sh

This is based on the old `wal` by Dylan Araps. All credit to him. `wal` generated color schemes for your desktop from wallpapers by using `imagemagick`.
I've edited it to write the generated colorscheme to the `i3`,`sway`, `termite` and Xresources config files and the following scripts in order to store them permanently.
The color configuration sections in the scripts and config files are currently emtpy. Execute the script in the follwing format
`wal.edit.sh -i Your/Wallpaper/Here` to fill these sections.

In the future, this functionality should be seperated from `wal` itself.

## config (i3 / sway)

My config file has shortcuts for my scripts for bluetooth, volume, brightness, `i3lock` / `swaylock` and `dmenu` built in.

## bluetoot.sh

This establishes a connection to an already paired and trusted bluetooth device in order to play audio with it.
It uses `bluetoothctl` and saves the sink of `pactl` to control the volume with volume.sh.

## volume.sh

This script controls the volume using `pactl` with the default sink or the sink of the connected bluetooth audio device.

## brightness.sh

`brightnessctl`is used to control the screenbrightness.

## lock.sh

Locks the screen using `i3lock` or `swaylock` (depending on which WM you chose). It uses some of the colors generated `ẁal`.

## dmenu.sh

Calls `dmenu` with some of the generated colors.
