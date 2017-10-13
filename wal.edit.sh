#!/usr/bin/env bash
#
# wal - Generate and change colorschemes on the fly.
#
# Created by Dylan Araps
# 
# Edited by mafenet to automate the use with .Xresources, Rofi and i3lock

# Speed up script by not using unicode.
sys_locale="$LANG"
export LC_ALL=C
export LANG=C

shopt -s nullglob nocasematch

# Internal variables.
cache_dir="${HOME}/.cache/wal"
newline=$'\n'
color_count=16
os="$(uname)"

# Scripts, in one Array for more efficient config
locksh="${HOME}/lock.sh"
dmenush="${HOME}/dmenu.sh"
scripts=( ${locksh} ${dmenush} )

# Config files for Xresources, i3 / sway, i3status, termite and dunst 
xres_file="${HOME}/.Xresources"

i3_sway_config="${HOME}/.config/i3/config"
if [[ $DESKTOP_SESSION == *"sway" ]];
	then i3_sway_config="${HOME}/.config/sway/config"
fi

termite_config="${HOME}/.config/termite/config"
dunstrc_file="${HOME}/.config/dunst/dunstrc"
i3stat_config="${HOME}/.config/i3status/config"

# The strings after which to insert the Colors and Wallpaper
colors_following="#Color config"
colors_following_xres="\!\!Color config"
wal_following="#Wallpaper config"
wal_following_xres="\!\!Wallpaper config"



# GENERATE COLORSCHEME

rand_img() {
    # Make glob fails silent.
    shopt -s nullglob

    # Create an array of images and exclude the current wallpaper.
    files=("${wal%/}"/*.{png,jpg,jpeg,jpe})
    files=("${files[@]/"$old_wall"}")

    # If no files were found, exit.
    if ((${#files[@]} == 0)); then
        out "error: No images were found, exiting..."
        exit 1
    fi

    # Reset glob.
   shopt -u nullglob

    # Pick a random image.
    wal="${files[RANDOM % ${#files[@]}]}"

    # Set the image to the first in the directory if the shuffle failes.
    [[ ! -f "$wal" ]] && wal="${files[0]}"

    out "image: Using image, $wal"
}

get_colors() {
    # Check for imagemagick.
    if ! type -p convert >/dev/null 2>&1; then
        out "error: imagemagick not found, exiting..."
        out "error: wal requires imagemagick to function."
        exit 1
    fi

    # Create the cache dir.
    mkdir -p "${cache_dir}/schemes"

    # Get the current wallpaper.
    [[ -f "${cache_dir}/wal" ]] && old_wall="$(< "${cache_dir}/wal")"

    # Shuffle the image.
    [[ -d "$wal" ]] && rand_img

    # If the wallpaper doesn't exist, use the current one.
    [[ ! -f "$wal" ]] && wal="$old_wall"

    # Store cached colorscheme as 'dir-to-img.jpg'
    cache_file="${cache_dir}/schemes/${wal//\//_}"

    # Cache the wallpaper name
    printf "%s\n" "$wal" > "${cache_dir}/wal"

    # Generate 16 colors from the image and save them to a file.
    if [[ -f "$cache_file" ]]; then
        colors=($(< "$cache_file"))
    else
        colors=($(convert "${wal}"  +dither -colors $color_count -unique-colors txt:- | grep -E -o " \#.{6}"))

        # If imagemagick finds less than 16 colors, use a larger source number of colors.
        while (( "${#colors[@]}" <= 15 )); do
            colors=($(convert "${wal}"  +dither -colors "$((color_count + ${index:-2}))" -unique-colors txt:- | grep -E -o " \#.{6}"))
            ((index++))
            out "colors: Imagemagick couldn't generate a $color_count color palette, trying a larger palette size ($((color_count + index)))."
        done

        # Cache the scheme.
        printf "%s\n" "${colors[@]}" > "$cache_file"
    fi

    out "colors: Generated colorscheme"
}


# SET COLORSCHEME


set_color() {
    sequences+="\033]4;${1};${2}\007"
    x_colors+="*color${1}: ${2}${newline}"
    sh_colors+="color${1}='${2}'${newline}"
    scss_colors+="\$color${1}: ${2};${newline}"
    plain+="${2}${newline}"
    
    #format as used in the config files, Switch-statement to avoid redundant empty lines.

    sway+="set \$color${1}	${2}"
    case "$1" in    
        0) sway+="\nset \$background	 ${2}\n" ;;
        1) sway+="\n" ;;
        2) sway+="\n" ;;
        3) sway+="\n" ;;
        4) sway+="\n" ;;
        5) sway+="\n" ;;
        6) sway+="\n" ;;
 	7) sway+="\nset \$foreground	 ${2}\n" ;;
        8) sway+="\n" ;;
        9) sway+="\n" ;;
        10) sway+="\n" ;;
        11) sway+="\n" ;;
        12) sway+="\n" ;;
        13) sway+="\n" ;;
        14) sway+="\n" ;;
    esac
   
    xres+="*color${1}: ${2}" 
    case "$1" in    
        0) xres+="\n*background: ${2}\n" ;;
        1) xres+="\n" ;;
        2) xres+="\n" ;;
        3) xres+="\n" ;;
        4) xres+="\n" ;;
        5) xres+="\n" ;;
        6) xres+="\n" ;;
 	7) xres+="\n*foreground: ${2}\n" ;;
        8) xres+="\n" ;;
        9) xres+="\n" ;;
        10) xres+="\n" ;;
        11) xres+="\n" ;;
        12) xres+="\n" ;;
        13) xres+="\n" ;;
        14) xres+="\n" ;;
    esac

    termite+="color${1} = ${2}"
   
    case "$1" in    
        0) termite+="\nbackground = ${2}\n" ;;
        1) termite+="\n" ;;
        2) termite+="\n" ;;
        3) termite+="\n" ;;
        4) termite+="\n" ;;
        5) termite+="\n" ;;
        6) termite+="\n" ;;
 	7) termite+="\nforeground = ${2}\n" ;;
        8) termite+="\n" ;;
        9) termite+="\n" ;;
        10) termite+="\n" ;;
        11) termite+="\n" ;;
        12) termite+="\n" ;;
        13) termite+="\n" ;;
        14) termite+="\n" ;;
    esac
    
    lock+="color${1}=${2}"
    case "$1" in
	0) lock+="\n" ;;
	1) lock+="\n" ;;
        2) lock+="\n" ;;
	3) lock+="\n" ;;
	4) lock+="\n" ;;
	5) lock+="\n" ;;
	6) lock+="\n" ;;
	7) lock+="\n" ;;
	8) lock+="\n" ;;
	9) lock+="\n" ;;
	10) lock+="\n" ;;
	11) lock+="\n" ;;
	12) lock+="\n" ;;
	13) lock+="\n" ;;
	14) lock+="\n" ;;
    esac
}

set_special() {
    sequences+="\033]${1};${2}\007"

    # Set X colors
    case "$1" in
        10) x_colors+="*foreground: ${2}${newline}" ;;
        11) x_colors+="*background: ${2}${newline}" ;;
        12) x_colors+="*cursor: ${2}${newline}" ;;
    esac
}

send_sequences() {
    # Create string of escape sequences to send to the terminals.
    set_special 10  "${colors[15]}"
    set_special 11  "${alpha:+[${alpha}]}${colors[0]}"
    set_special 12  "${colors[15]}"
    set_special 13  "${colors[15]}"
    set_special 14  "${alpha:+[${alpha}]}${colors[0]}"

    # This escape sequence doesn't work in VTE terminals.
    [[ "$vte" != "on" ]] && set_special 708 "${alpha:+[${alpha}]}${colors[0]}"

    set_color 0  "${colors[0]}"
    set_color 1  "${colors[9]}"
    set_color 2  "${colors[10]}"
    set_color 3  "${colors[11]}"
    set_color 4  "${colors[12]}"
    set_color 5  "${colors[13]}"
    set_color 6  "${colors[14]}"
    set_color 7  "${colors[15]}"

    # Create a comment color based on the brightness of the background.
    case "${colors[0]:1:1}" in
        [0-1]) set_color 8 "#666666" ;;
        2)     set_color 8 "#757575" ;;
        [3-4]) set_color 8 "#999999" ;;
        5)     set_color 8 "#8a8a8a" ;;
        [6-9]) set_color 8 "#a1a1a1" ;;
        *)     set_color 8 "${colors[7]}" ;;
    esac

    set_color 9  "${colors[9]}"
    set_color 10 "${colors[10]}"
    set_color 11 "${colors[11]}"
    set_color 12 "${colors[12]}"
    set_color 13 "${colors[13]}"
    set_color 14 "${colors[14]}"
    set_color 15 "${colors[15]}"

    # Directing output to /dev/pts/* allows you to send output to all open terminals
    # on your system.
    for term in /dev/pts/[0-9]*; do
        printf "%b" "$sequences" > "$term" &
    done

    out "colors: Set terminal colors"
}

set_wallpaper() {
    if [[ -z "$nowall" ]]; then
        # Get desktop environment.
        de="${XDG_CURRENT_DESKTOP}"

        # Fallback to using xprop.
        [[ -z "$de" ]] && type -p xprop >/dev/null 2>&1 && \
            de="$(xprop -root | awk '/KDE_SESSION_VERSION|^_MUFFIN|xfce4|xfce5/')"

        case "$de" in
            *"MUFFIN"* | *"Cinnamon"*) gsettings set org.cinnamon.desktop.background picture-uri "file://${wal}" ;;
            *"MATE"*) gsettings set org.mate.background picture-filename "$wal" ;;
            *"GNOME"*) gsettings set org.gnome.desktop.background picture-uri "file://${wal}" ;;

            *"XFCE"*)
                xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set "$wal" 2>/dev/null
                xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace0/last-image --set "$wal" 2>/dev/null
            ;;

            *)
                if type -p feh >/dev/null; then
                    feh --bg-fill "$wal"

                elif type -p nitrogen >/dev/null; then
                    nitrogen --set-zoom-fill "$wal"

                elif type -p bgs >/dev/null; then
                    bgs "$wal"

                elif type -p hsetroot >/dev/null; then
                    hsetroot -fill "$wal"

                elif type -p habak >/dev/null; then
                    habak -mS "$wal"

                elif [[ "$os" == "Darwin" ]]; then
                    osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'"${wal/#\~/$HOME}"\"

                else
                    gsettings set org.gnome.desktop.background picture-uri "file://${wal}"
                fi
            ;;
        esac

	sed -i "/#Wallpaper configuration*/a output * bg ${wal} fill" ${sway_config}

        out "wallpaper: Set new wallpaper"
    else
        out "wallpaper: '-n' was used, skipping wallpaper"
    fi
}


# EXPORT COLORS

export_plain() {
    printf "%s" "$plain"
    out "export: Exported plain colors"
}

export_sequences() {
    printf "%s" "$sequences"
    out "export: Exported escape sequences"
}

export_envar() {
    printf "%s\n%s" "# wal - Colors generated by wal " "$sh_colors"
    out "export: Exported sh colors"
}

export_scss() {
    printf "%s\n%s" "// wal - Colors generated by wal " "$scss_colors"
    out "export: Exported scss color variables"
}
	

# export colors into the .Xresources file, inserting after !!Color comment
export_xres() {	
    if grep -q "${colors_following_xres}" ${xres_file}; then
	echo Yep
    else
	echo ${xres} >> ${xres_file}	
    fi	
    sed -i "/${colors_following_xres} ${xres}" ${xres_file} 
    out "export: Exported colors into Xresources"
}

# export colors into the i3 or sway configuration files, inserting at the top
export_i3_sway() {	
    if grep -q "${colors_following}" ${i3_sway_config}; then
	echo Yep
    else
	sed -i "/reference/a ${colors_following}" ${i3_sway_config}
    fi	
    sed -i "/${colors_following}/a ${sway}" ${i3_sway_config} 
    out "export: Exported colors into Xresources"
}

# export colors into the termite configuration file in the [colors] section
export_termite() {
    sed -i "/\[colors\]/a ${termite}" ${termite_config}
    out "export: Exported colors into termite config file"	   
}

# export colors into the config for the dunst notification daemon for automated adjustment
export_dunst() {
    sed -i "/^color/ s/\#[[:alnum:]]\{6\}/${colors[7]}/" $dunstrc

    sed -i "/^foreground/ s/\#[[:alnum:]]\{6\}/${colors[14]}/" $dunstrc

    sed -i "/^background/ s/\#[[:alnum:]]\{6\}/${colors[0]}/" $dunstrc
    out "export: Exported colors into Dunst Config"
}

# export colors into the config for the i3status module for automated adjustment
export_status() {
    sed -i "/color_good/ s/\#[[:alnum:]]\{6\}/${colors[15]}/" ${i3stat_config}
	#12
    sed -i "/color_bad/ s/\#[[:alnum:]]\{6\}/${colors[8]}/" ${i3stat_config}
	#6
    sed -i "/color_degraded/ s/\#[[:alnum:]]\{6\}/${colors[2]}/" ${i3stat_config}
        #3
    out "export: Exported colors into i3status Config"
}

# export colors into both lock.sh for i3/swaylock and dmenu.sh
export_scripts() {
    for s in "${scripts[@]}"
    do
	echo ${s}
    	if grep -q "${colors_following}" ${s}; then
		echo Yep
	    else
		sed -i "/#\!\/bin\/bash/a ${colors_following}" ${s}
        fi	
    	sed -i "/${colors_following}/a ${lock}" ${s} 
    	sed -i "/${colors_following}/a wal=${wal}" ${s}
    	out "export: Exported colors into script for i3lock"
    done
}

# exporting wallpaper. 
export_wal() { 
    # sed -i "/${wal_following_xres}/a \*wal: ${wal}" $xres_file
    sed -i "/${wal_following}/a set \$wal ${wal}" $i3_sway_config
    out "export: Exported colors for rofi into Xresources"
}

 
export_rofi() {
    rofi_bg="argb:${alpha:-FF}${colors[0]/\#}"
    x_colors+="rofi.color-window: ${rofi_bg}, ${colors[0]}, ${colors[10]}${newline}"
    x_colors+="rofi.color-normal: ${rofi_bg}, ${colors[15]}, ${colors[0]}, ${colors[10]}, ${colors[0]}${newline}"
    x_colors+="rofi.color-active: ${rofi_bg}, ${colors[15]}, ${colors[0]}, ${colors[10]}, ${colors[0]}${newline}"
    x_colors+="rofi.color-urgent: ${rofi_bg}, ${colors[9]}, ${colors[0]}, ${colors[9]}, ${colors[15]}${newline}"
}

# export colors for rofi into the Xresources configuration file
export_rofi_xres() {
    
    rofi="rofi.color-enabled: true\n"
    rofi+="rofi.color-window: ${colors[0]}, ${colors[0]}, ${colors[10]}\n"
    rofi+="rofi.color-normal: ${colors[0]}, ${colors[15]}, ${colors[0]}, ${colors[10]}, ${colors[0]}\n"
    rofi+="rofi.color-active: ${colors[0]}, ${colors[15]}, ${colors[0]}, ${colors[10]}, ${colors[0]}\n"
    rofi+="rofi.color-urgent: ${colors[0]}, ${colors[9]}, ${colors[0]}, ${colors[9]}, ${colors[15]}\n"
    rofi+="rofi.separator-style: solid"
  
    sed -i "/\!\!Rofi*/a ${rofi}" ${xres_file}
    out "export: Exported colors for rofi into Xresources"
}

# delete the previos color configuration from all configuration files
garbage_collection () {
    sed -i "/\*wal*/d" ${xres_file}  
    sed -i "/\**ground*/d" ${xres_file}
    sed -i "/^foreground*/d" ${termite_config}
    sed -i "/^background*/d" ${termite_config}
    sed -i "/^color[0-9]/d" ${termite_config}
    
    sed -i "/^set \$color[0-9]*/d" ${i3_sway_config}
    sed -i "/^set \$foreground*/d" ${i3_sway_config}
    sed -i "/^set \$background*/d" ${i3_sway_config}
    sed -i "/^set \$wal*/d" ${i3_sway_config}

    sed -i "/\*col*/d" ${xres_file}
    sed -i "/rofi.*/d" ${xres_file}
     
    for s in "${scripts[@]}"
    do
    	sed -i "/^.*=#[[:alnum:]]\{6\}$/d" ${s}
    	sed -i "/^.*\.[jpegnif]\{3,4\}$/d" ${s}
    done
}

export_colors() {
    export_sequences > "${cache_dir}/sequences"
    export_envar     > "${cache_dir}/colors.sh"
    export_scss      > "${cache_dir}/colors.scss"
    export_rofi
    export_plain     > "${cache_dir}/colors"
    garbage_collection
    #export_xres
    #export_rofi_xres 
    export_i3_sway
    export_termite
    export_wal
    export_dunst
    export_status
    #export_lock
    #export_dmenu
    export_scripts
}

# RELOAD COLORSCHEME

reload_colors() {
    # Source the current sequences
    sequences="$(< "${HOME}/.cache/wal/sequences")"

    # If vte mode was used, remove the problem sequence.
    [[ "$vte" == "on" ]] && sequences="${sequences/??\]708\;\#??????}"

    printf "%b" "$sequences"
    exit
}

reload_env() {
    # Reload i3 if running.
    pgrep i3 && i3-msg reload &
}

reload_xrdb() {
    [[ "$alpha" ]] && x_colors+="URxvt.depth: 32${newline}"

    # Merge the colors into the X db so new terminals use them.
    xrdb -merge >/dev/null 2>&1 <<< "$x_colors" && \
        out "colors: Merged colors with X env"
}

# OTHER

get_full_path() {
    # Go to the relative PATH.
    if ! cd "${1%/*}"; then
        printf "%s\n" "Error: Directory '$1' doesn't exist or is inaccessible" >&2
        printf "%s\n" "       Check that the directory exists or try another directory." >&2
        exit 1
    fi

    # Final directory.
    img_dir="$(pwd -P)"
    img="${1/*\/}"

    if [[ -e "${img_dir}/${img}" ]]; then
        printf "%s\n" "${img_dir}/${1/*\/}"

    else
        printf "%s\n" "Error: File: '${img_dir}/${img}' not found." >&2
        printf "%s\n" "       Check that the file exists or try another file." >&2
        exit 1
    fi
}

out() {
    [[ "$quiet" != "on" ]] && printf "%s\n" "$1" >&2
}

usage() { printf "%s" "\
Usage: wal [OPTION] -i '/path/to/dir'
Example: wal -i '${HOME}/Pictures/Wallpapers/'
         wal -i '${HOME}/Pictures/1.jpg'
Flags:
  -a                      Set terminal background alpha channel (vulgo transparency). *Only works in URxvt*
  -c                      Delete all cached colorschemes.
  -h                      Display this help page.
  -i '/path/to/dir'       Which image to use.
     '/path/to/img.jpg'
  -n                      Skip setting the wallpaper.
  -o 'script_name'        External script to run after 'wal'.
  -q                      Quiet mode, don't print anything.
  -r                      Reload current colorscheme.
  -t                      Fix artifacts in VTE Terminals. (Termite, xfce4-terminal)
"
}

get_args() {
    while getopts ":a:chi:no:qrt" opt; do
        case "$opt" in
            "a") alpha="$OPTARG" ;;
            "c") rm -rf "${cache_dir}/schemes"; exit ;;
            "h") usage; exit 1 ;;

            "i")
                [[ -f "${PWD}/${OPTARG/*\/}" ]] && wal="${PWD}/${OPTARG/*\/}"
                [[ -z "$wal" ]] && wal="$(get_full_path "$OPTARG")"
            ;;

            "n") nowall="on" ;;
            "o") external_script=("$OPTARG") ;;
            "q") quiet="on" ;;
            "r") reload="on" ;;
            "t") vte="on" ;;

            "?")
                printf "%s\n" "Invalid option: -$OPTARG" >&2
                exit 1
            ;;

            ":")
                printf "%s\n" "Option -$OPTARG requires an argument." >&2
                exit 1
            ;;
        esac
    done

    # Reload colors.
    [[ "$reload" == "on" ]] && reload_colors

    # Check if -i was used.
    if [[ -z "$wal" ]]; then
        printf "%s\n" "Error: 'wal' must be run with '-i'" >&2
        printf "%s\n" "Try 'wal -h' for more information." >&2
        exit 1
    fi
}


# FINISH UP


main () {
    get_args "$@"

    get_colors
    send_sequences
    set_wallpaper
    export_colors
    reload_xrdb
    reload_env >/dev/null 2>&1

    # Set the locale back to the original value.
    export LC_ALL="$sys_locale"

    # Execute custom script.
    [[ "${external_script[0]}" ]] && bash -c "${external_script[@]}"
}

main "$@"
