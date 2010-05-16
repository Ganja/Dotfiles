#!/bin/bash
# VolWheel
(sleep 3s && volwheel) &
# Fbxkb keymap
setxkbmap se &
(sleep 1s && fbxkb) &
# Nm-applet network
(sleep 4s && nm-applet) &
# PowerManager
xfce4-power-manager &
# Thunar
thunar --daemon &
# Set desktop wallpaper
nitrogen --restore &
# Urxvt daemon
urxvtd -q -o -f &

# this starts mpd as normal user
mpd /home/ganja/.mpd/mpd.conf 

exec /usr/bin/awesome
