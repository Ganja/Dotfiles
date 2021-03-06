#!/bin/bash

#
# screenFetch (v1.7.9)
#
# Script to fetch system and theme settings for screenshots in most mainstream
# Linux distributions.
# This script is copyright (C) 2010 to Brett Bohnenkamper (kittykatt@archlinux.us)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.
#
# Yes, I do realize some of this is horribly ugly coding. Any ideas/suggestions would be
# appreciated by emailing me or by stopping by http://github.com/KittyKatt/screeFetch . You
# could also drop in on my IRC network, SilverIRC, at irc://kittykatt.silverirc.com:6669/meowz
# to put forth suggestions/ideas. Thank you.
#

scriptVersion="1.7.9"

######################
# Settings for fetcher
######################

# This setting controls what ASCII logo is displayed. Available: Linux Mint, Arch Linux, Ubuntu, Debian, BSD, Crunchbang, Gentoo, Fedora, None
# distro="Arch Linux"

# This sets the information to be displayed. Available: OS, Kernel, DE, WM, Win_theme, Theme, Icons, Font, ASCII. To get just the information, and not a text-art logo, you would take "ASCII" out of the below variable.
display="OS Kernel Uptime DE WM Win_theme Theme Icons Font ASCII"

# Colors to use for the information found. These are set below according to distribution. If you would like to set your OWN color scheme for these, uncomment the lines below and edit them to your heart's content.
# textcolor="\e[0m"
# labelcolor="\e[1;34m"

# WM & DE process names
wmnames="fluxbox openbox blackbox xfwm4 metacity kwin icewm pekwm fvwm dwm awesome WindowMaker"
denames="gnome-session xfce-mcs-manage xfce4-session ksmserver lxsession gnome-settings-daemon"

# Screenshot Settings
# This setting lets the script know if you want to take a screenshot or not. 1=Yes 0=No
screenshot=0
# You can specify a custom screenshot command here. Just uncomment and edit. Otherwise, we'll be using the default command: scrot -cd3.
# screenCommand="scrot -cd5"

# Verbose Setting - Set to 1 for verbose output.
verbosity=0

verboseOut () {
  echo -e "\e[1;31m:: \e[0m$1"
}

#############################################
#### CODE No need to edit past here CODE ####
#############################################

####################
# Static Variables
####################
c0="\e[0m" # Reset Text
bold="\e[1m" # Bold Text
underline="\e[4m" # Underline Text


#####################
# Begin Flags Phase
#####################

while getopts ":hsvVnlc:D:" flags; do
  case $flags in
    h)
      echo -e "${underline}Usage${c0}:"
      echo -e "  screenFetch [OPTIONAL FLAGS]"
      echo ""
      echo "screenFetch - a CLI Bash script to show system/theme info in screenshots."
      echo ""
      echo -e "${underline}Supported Distributions${c0}:      Arch Linux, Linux Mint, Ubuntu, Crunchbang, Debian, Fedora, and BSD"
      echo -e "${underline}Supported Desktop Managers${c0}:   KDE, GNOME, XFCE, and LXDE, and Not Present"
      echo -e "${underline}Supported Window Managers${c0}:    PekWM, OpenBox, FluxBox, BlackBox, Xfwm4m, Metacity, KWin, IceWM, FVWM, DWM, Awesome, and WindowMaker"
      echo ""
      echo -e "${underline}Options${c0}:"
      echo -e "   ${bold}-v${c0}                 Verbose output."
      echo -e "   ${bold}-n${c0}                 Do no display ASCII distribution logo."
      echo -e "   ${bold}-s${c0}                 Using this flag tells the script that you want it to take a screenshot."
      echo -e "   ${bold}-l${c0}                 Specify that you have a light background. This turns all white text into dark gray text (in ascii logos and in information output)."
      echo -e "   ${bold}-c 'COMMAND'${c0}       Here you can specify a custom screenshot command for the script to execute. Surrounding quotes are required."
      echo -e "   ${bold}-D 'DISTRO'${c0}        Here you can specify your distribution for the script to use. Surrounding quotes are required."
      echo -e "   ${bold}-V${c0}                 Display current script version."
      echo -e "   ${bold}-h${c0}                 Display this help."
      exit
    ;;
    s) screenshot=1; continue;;
    v) verbosity=1; continue;;
    V)
      echo -e $underline"screenFetch"$c0" - Version $scriptVersion"
      echo "Copyright (C) Brett Bohnenkamper (kittykatt@archlinux.us)"
      echo ""
      echo "This is free software; see the source for copying conditions.  There is NO
warranty; not even MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
      exit
    ;;
    D) distro=$OPTARG; continue;;
    c) screenCommand=$OPTARG; continue;;
    n) display=${display//ASCII/};;
    l) c1="\e[1;30m";;
    :) echo "Error: You're missing an argument somewhere. Exiting."; exit;;
    ?) echo "Error: Invalide flag somewhere. Exiting."; exit;;
    *) echo "Error"; exit;;
  esac
 done

###################
# End Flags Phase
###################


#########################
# Begin Detection Phase
#########################

# Distro Detection - Begin
detectdistro () {
  if [[ -z $distro ]]; then
    distro="Unknown"
    if grep -i debian /etc/lsb-release >/dev/null 2>&1; then distro="Debian"; fi
    if grep -i ubuntu /etc/lsb-release >/dev/null 2>&1; then distro="Ubuntu"; fi
    if grep -i mint /etc/lsb-release >/dev/null 2>&1; then distro="Linux Mint"; fi
    if [ -f /etc/arch-release ]; then distro="Arch Linux"; fi
    if [ -f /etc/fedora-release ]; then distro="Fedora"; fi
    if [ -f /etc/redhat-release ]; then distro="Red Hat Linux"; fi
    if [ -f /etc/slackware-version ]; then distro="Slackware"; fi
    if [ -f /etc/SUSE-release ]; then distro="SUSE"; fi
    if [ -f /etc/mandrake-release ]; then distro="Mandrake"; fi
    if [ -f /etc/mandriva-release ]; then distro="Mandriva"; fi
    if [ -f /etc/crunchbang-lsb-release ]; then distro="Crunchbang"; fi
    if [ -f /etc/gentoo-release ]; then distro="Gentoo"; fi
    if [ -f /var/run/dmesg.boot ] && grep -i bsd /var/run/dmesg.boot; then distro="BSD"; fi
    if [ -f /usr/share/doc/tc/release.txt ]; then distro="Tiny Core"; fi
  fi
  [ "$verbosity" -eq "1" ] && verboseOut "Finding distro...found as '$distro'"
}
# Distro Detection - End

# Find Number of Running Processes
processnum="$(( $( ps aux | wc -l ) - 1 ))"

# Kernel Version Detection - Begin
detectkernel () {
  kernel=`uname -r`
  [ "$verbosity" -eq "1" ] && verboseOut "Finding kernel version...found as '$kernel'"
}
# Kernel Version Detection - End


# Uptime Detection - Begin
detectuptime () {
  uptime=`awk -F. '{print $1}' /proc/uptime`
  secs=$((${uptime}%60))
  mins=$((${uptime}/60%60))
  hours=$((${uptime}/3600%24))
  days=$((${uptime}/86400))
  uptime="${mins}m"
  if [ "${hours}" -ne "0" ]; then
    uptime="${hours}h ${uptime}"
    if [ "${days}" -ne "0" ]; then
      uptime="${days}d ${uptime}"
    fi
  fi
  [ "$verbosity" -eq "1" ] && verboseOut "Finding current uptime...found as '$uptime'"
}
# Uptime Detection - End


# DE Detection - Begin
detectde () {
  DE="Not Present"
  for each in $denames; do
    if pidof $each >/dev/null; then
      [ "$each" == "gnome-session" -o "$each" == "gnome-settings-daemon" ] && DE="GNOME" && DEver=`gnome-session --version | awk {'print $NF'}`
      [ "$each" == "xfce-mcs-manage" -o "$each" == "xfce4-session" ] && DE="XFCE" && DEver=`xfce4-settings-manager --version | grep -m 1 "" | awk {'print $2'}`
      [ "$each" == "ksmserver" ] && DE="KDE" && DEver=`kwin --version | awk '/^Qt/ {data="Qt v" $2};/^KDE/ {data=$2 " (" data ")"};END{print data}'`
      [ "$each" == "lxsession" ] && DE="LXDE"
    fi
  done
  [ "$verbosity" -eq "1" ] && verboseOut "Finding desktop environment...found as '$DE'"
}
### DE Detection - End


# WM Detection - Begin
detectwm () {
  WM="Not Found"
  for each in $wmnames; do
    if pidof $each >/dev/null; then
      case $each in
        'fluxbox') WM="FluxBox";;
        'openbox') WM="OpenBox";;
        'blackbox') WM="blackbox";;
        'xfwm4') WM="Xfwm4";;
        'metacity') WM="Metacity";;
        'kwin') WM="KWin";;
        'icewm') WM="IceWM";;
        'pekwm') WM="PekWM";;
        'fvwm') WM="FVWM";;
        'dwm') WM="DWM";;
        'awesome') WM="Awesome";;
        'WindowMaker') WM="WindowMaker";;
      esac
    fi
  done
  [ "$verbosity" -eq "1" ] && verboseOut "Finding window manager...found as '$WM'"
}
# WM Detection - End


# WM Theme Detection - BEGIN
detectwmtheme () {
  Win_theme="Not Found"
  case $WM in
    'PekWM') if [ -f $HOME/.pekwm/config ]; then Win_theme=`awk -F"/" '/Theme/ {gsub(/\"/,""); print $NF}' $HOME/.pekwm/config`; fi;;
    'OpenBox') if [ -f $HOME/.config/openbox/rc.xml ]; then Win_theme=`awk -F"[<,>]" '/<theme/ { getline; print $3 }' $HOME/.config/openbox/rc.xml`; elif [ -f $HOME/.config/openbox/lxde-rc.xml ]; then Win_theme=`awk -F"[<,>]" '/<theme/ { getline; print $3 }' $HOME/.config/openbox/lxde-rc.xml`; fi;;
    'FluxBox') if [ -f $HOME/.fluxbox/init ]; then Win_theme=`awk -F"/" '/styleFile/ {print $NF}' $HOME/.fluxbox/init`; fi;;
    'BlackBox') if [ -f $HOME/.blackboxrc ]; then Win_theme=`awk -F"/" '/styleFile/ {print $NF}' $HOME/.blackbox/init`; fi;;
    'Metacity') if gconftool-2 -g /apps/metacity/general/theme; then Win_theme=`gconftool-2 -g /apps/metacity/general/theme`; fi;;
    'XFCE') if [ -f $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml ]; then Win_theme=`xfconf-query -c xfwm4 -p /general/theme`; fi;;
    'IceWM') if [ -f $HOME/.icewm/theme ]; then Win_theme=`awk -F"[\",/]" '!/#/ {print $2}' $HOME/.icewm/theme`; fi;;
    'KWin') if [ -f $HOME/.kde/share/config/kwinrc ]; then Win_theme=`awk -F"[<,>]" '/<theme/ { getline; print $3 }' $HOME/.config/openbox/rc.xml`; fi;;
    'Emerald') if [ -f $HOME/.emerald/theme/theme.ini ]; then Win_theme=`for a in /usr/share/emerald/themes/* $HOME/.emerald/themes/*; do cmp "$HOME/.emerald/theme/theme.ini" "$a/theme.ini" &>/dev/null && basename "$a"; done`; fi;;
    'FVWM') Win_theme="Not Present";;
    'DWM') Win_theme="Not Present";;
    'Awesome') if [ -f $HOME/.config/awesome/rc.lua ]; then Win_theme=`grep -e '\(theme\|beautiful\).*lua' $HOME/.config/awesome/rc.lua | grep '[a-zA-Z0-9]\+/[a-zA-Z0-9]\+.lua' -o | cut -d'/' -f1`; fi;;
    'WindowMaker') Win_theme="Not Present";;
    esac
  [ "$verbosity" -eq "1" ] && verboseOut "Finding window manager theme...found as '$Win_theme'"
}
# WM Theme Detection - END

# awk -F"= " '/theme.name/ {print $2}' /home/kittykatt/.e16/e_config--0.0.cfg

# try for a in /usr/share/emerald/themes/* $HOME/.emerald/themes/*; do cmp "$HOME/.emerald/theme/theme.ini" "$a/theme.ini" &>/dev/null && basename "$a"; done

# GTK Theme\Icon\Font Detection - BEGIN
detectgtk () {
  gtkTheme="Not Found"
  gtkIcons="Not Found"
  gtkFont="Not Found"
  case $DE in
    'KDE')  # Desktop Environment found as "KDE"
          if [ -a $HOME/.kde/share/config/kdeglobals ]; then
            if grep -q "widgetStyle=" $HOME/.kde/share/config/kdeglobals; then
              gtkTheme=$(awk -F"=" '/widgetStyle=/ {print $2}' $HOME/.kde/share/config/kdeglobals)
            elif grep -q "colorScheme=" $HOME/.kde/share/config/kdeglobals; then
              gtkTheme=$(awk -F"=" '/colorScheme=/ {print $2}' $HOME/.kde/share/config/kdeglobals)
            fi

            if [[ "$display" =~ "Icons" ]] && grep -q "Theme=" $HOME/.kde/share/config/kdeglobals; then
              gtkIcons=$(awk -F"=" '/Theme=/ {print $2}' $HOME/.kde/share/config/kdeglobals)
            fi

            if [[ "$display" =~ "Font" ]] && grep -q "Font=" $HOME/.kde/share/config/kdeglobals; then
                gtkFont=$(awk -F"=" '/Font=/ {print $2}' $HOME/.kde/share/config/kdeglobals)
            fi
          fi
  ;;
  'GNOME')  # Desktop Environment found as "GNOME"
          if which gconftool >/dev/null 2>&1; then
            gtkTheme=$(gconftool-2 -g /desktop/gnome/interface/gtk_theme)
          fi

          if [[ "$display" =~ "Icons" ]] && which gconftool >/dev/null 2>&1; then
              gtkIcons=$(gconftool-2 -g /desktop/gnome/interface/icon_theme)
          fi

          if [[ "$display" =~ "Font" ]] && which gconftool >/dev/null 2>&1; then
            gtkFont=$(gconftool-2 -g /desktop/gnome/interface/font_name)
          fi
  ;;
  'XFCE')  # Desktop Environment found as "XFCE"
         if which xfconf-query >/dev/null 2>&1; then
           gtkTheme=$(xfconf-query -c xsettings -p /Net/ThemeName)
         fi

         if [[ "$display" =~ "Icons" ]] && which xfconf-query >/dev/null 2>&1; then
           gtkIcons=$(xfconf-query -c xsettings -p /Net/IconThemeName)
         fi

         if [[ "$display" =~ "Font" ]] && which xfconf-query >/dev/null 2>&1; then
           gtkFont=$(xfconf-query -c xsettings -p /Gtk/FontName)
         fi
  ;;

# /home/me/.config/rox.sourceforge.net/ROX-Session/Settings.xml

  *) # Lightweight or No DE Found
    if [ -f $HOME/.gtkrc-2.0 ]; then
      if grep -q gtk-theme $HOME/.gtkrc-2.0; then 
         gtkTheme=$(awk -F'"' '/gtk-theme/ {print $2}' $HOME/.gtkrc-2.0)
      fi

      if [[ "$display" =~ "Icons" ]] && grep -q icon-theme $HOME/.gtkrc-2.0; then
          gtkIcons=$(awk -F'"' '/icon-theme/ {print $2}' $HOME/.gtkrc-2.0)
      fi

      if [[ "$display" =~ "Font" ]] && grep -q font $HOME/.gtkrc-2.0; then
          gtkFont=$(awk -F'"' '/font/ {print $2}' $HOME/.gtkrc-2.0)
      fi
    # LXDE
    elif [ -f $HOME/.config/lxde/config ]; then
      if grep -q "sNet\/ThemeName" $HOME/.config/lxde/config; then 
         gtkTheme=$(awk -F'=' '/sNet\/ThemeName/ {print $2}' $HOME/.config/lxde/config)
      fi

      if [[ "$display" =~ "Icons" ]] && grep -q IconThemeName $HOME/.config/lxde/config; then
          gtkIcons=$(awk -F'=' '/sNet\/IconThemeName/ {print $2}' $HOME/.config/lxde/config)
      fi

      if [[ "$display" =~ "Font" ]] && grep -q FontName $HOME/.config/lxde/config; then
          gtkFont=$(awk -F'=' '/sGtk\/FontName/ {print $2}' $HOME/.config/lxde/config)
      fi
    fi
    # $HOME/.gtkrc.mine theme detect only
    if [ -f $HOME/.gtkrc.mine ]; then
      if grep -q "^include" $HOME/.gtkrc.mine; then
        gtkTheme=$(awk -F"/" '/^include/ { getline; print $5}' $HOME/.gtkrc.mine)
      fi
    fi
    # ROX-Filer icon detect only
    if [ -a $HOME/.config/rox.sourceforge.net/ROX-Filer/Options ]; then
      gtkIcons=$(awk -F'[>,<]' '/icon_theme/ {print $3}' $HOME/.config/rox.sourceforge.net/ROX-Filer/Options)
    fi
  ;;
  esac
  if [ "$verbosity" -eq "1" ]; then
    verboseOut "Finding GTK theme...found as '$gtkTheme'"
    verboseOut "Finding icon theme...found as '$gtkIcons'"
    verboseOut "Finding user font...found as '$gtkFont'"
  fi
}
# GTK Theme\Icon\Font Detection - END

#######################
# End Detection Phase
#######################


takeShot () {
  if [[ -z $screenCommand ]]; then
    scrot -cd3 'screenFetch-%Y-%m-%d.png'
  else
    $screenCommand
  fi
}


asciiText () {
case $distro in
  "Arch Linux")
    [ -z $c1 ] && c1="\e[1;37m" # White
    c2="\e[1;34m" # Light Blue
    echo -e "$c1              __"
    echo -e "$c1          _=(SDGJT=_"
    echo -e "$c1        _GTDJHGGFCVS)                $OS"
    echo -e "$c1       ,GTDJGGDTDFBGX0               $kernel"
    echo -e "$c1      JDJDIJHRORVFSBSVL$c2-=+=,_        $uptime"
    echo -e "$c1     IJFDUFHJNXIXCDXDSV,$c2  \"DEBL      $DE"
    echo -e "$c1    [LKDSDJTDU=OUSCSBFLD.$c2   '?ZWX,   $WM"
    echo -e "$c1   ,LMDSDSWH'     \`DCBOSI$c2     DRDS], $WM_theme"
    echo -e "$c1   SDDFDFH'         !YEWD,$c2   )HDROD  $GTK_theme"
    echo -e "$c1  !KMDOCG            &GSU|$c2\_GFHRGO\' $GTK_icons"
    echo -e "$c1  HKLSGP'$c2           __$c1\TKM0$c2\GHRBV)'  $GTK_font"
    echo -e "$c1 JSNRVW'$c2       __+MNAEC$c1\IOI,$c2\BN'"
    echo -e "$c1 HELK['$c2    __,=OFFXCBGHC$c1\FD)"
    echo -e "$c1 ?KGHE $c2\_-#DASDFLSV='$c1    'EF"
    echo -e "$c1 'EHTI                    !H"
    echo -e "$c1  \`0F'                    '!"$c0
  ;;

  "Linux Mint")
    [ -z $c1 ] && c1="\e[1;37m" # White
    c2="\e[1;32m" # Bold Green
    echo -e "$c2 MMMMMMMMMMMMMMMMMMMMMMMMMmds+."
    echo -e "$c2 MMm----::-://////////////oymNMd+\`"
    echo -e "$c2 MMd      "$c1"/++                "$c2"-sNMd:   $OS"
    echo -e "$c2 MMNso/\`  "$c1"dMM    \`.::-. .-::.\` "$c2".hMN:  $kernel"
    echo -e "$c2 ddddMMh  "$c1"dMM   :hNMNMNhNMNMNh: "$c2"\`NMm  $uptime"
    echo -e "$c2     NMm  "$c1"dMM  .NMN/-+MMM+-/NMN\` "$c2"dMM  $DE"
    echo -e "$c2     NMm  "$c1"dMM  -MMm  \`MMM   dMM. "$c2"dMM  $WM"
    echo -e "$c2     NMm  "$c1"dMM  -MMm  \`MMM   dMM. "$c2"dMM  $WM_theme"
    echo -e "$c2     NMm  "$c1"dMM  .mmd  \`mmm   yMM. "$c2"dMM  $GTK_theme"
    echo -e "$c2     NMm  "$c1"dMM\`  ..\`   ...   ydm. "$c2"dMM  $GTK_icons"
    echo -e "$c2     hMM- "$c1"+MMd/-------...-:sdds  "$c2"dMM  $GTK_font"
    echo -e "$c2     -NMm- "$c1":hNMNNNmdddddddddy/\`  "$c2"dMM"
    echo -e "$c2      -dMNs-"$c1"\`\`-::::-------.\`\`    "$c2"dMM"
    echo -e "$c2       \`/dMNmy+/:-------------:/yMMM"
    echo -e "$c2          ./ydNMMMMMMMMMMMMMMMMMMMMM"$c0
  ;;

  "Ubuntu")
    [ -z $c1 ] && c1="\e[1;37m" # White
    c2="\e[1;31m" # Light Red
    c3="\e[1;33m" # Bold Yellow
    echo -e "$c2                          ./+o+-"
    echo -e "$c1                  yyyyy- $c2-yyyyyy+"
    echo -e "$c1               $c1://+//////$c2-yyyyyyo"
    echo -e "$c3           .:: $c1.:/++++++/-$c2.+sss/\`     $OS"
    echo -e "$c3         .:----  $c1/++++++++/:--:/-     $kernel"
    echo -e "$c3        -:---:::.$c1\`..\`\`\`.-/oo+++++/    $uptime"
    echo -e "$c3       .:--:::/.$c1          \`+sssoo+/   $DE"
    echo -e "$c1  .:+/+:$c3-----:\`$c1             /sssooo.  $WM"
    echo -e "$c1 -+++//+:$c3\`----$c1               /::--:.  $WM_theme"
    echo -e "$c1 -+/+:+++$c3\`----$c2               ++////.  $GTK_theme"
    echo -e "$c1  .++.:+$c3-----:\`$c2             /dddhhh.  $GTK_icons"
    echo -e "$c3       .-.----:.$c2          \`oddhhhh+   $GTK_font"
    echo -e "$c3        -:.-----\`\`-\`\`$c2\`\`.:ohdhhhhh+"
    echo -e "$c3         \`:---- $c2\`ohhhhhhhhyo++os:"
    echo -e "$c3           .-:$c2\`.syhhhhhhh/$c3.--::-\`"
    echo -e "$c2               /osyyyyyyo$c3-------/"
    echo -e "$c2                   \`\`\`\`\` $c3-:-....:"
    echo -e "$c3                          \`----."$c0
  ;;

  "Debian")
    [ -z $c1 ] && c1="\e[1;37m" # White
    c2="\e[1;31m" # Light Red
    echo -e "  $c1       _,met\$\$\$\$\$gg."
    echo -e "  $c1    ,g\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$P."
    echo -e "  $c1  ,g\$\$P\"\"       \"\"\"Y\$\$.\"."
    echo -e "  $c1 ,\$\$P'              \`\$\$\$.      $OS"
    echo -e "  $c1',\$\$P       ,ggs.     \`\$\$b:    $kernel"
    echo -e "  $c1\`d\$\$'     ,\$P\"\'   $c2.$c1    \$\$\$    $uptime"
    echo -e "  $c1 \$\$P      d\$\'     $c2,$c1    \$\$P    $DE"
    echo -e "  $c1 \$\$:      \$\$.   $c2-$c1    ,d\$\$'     $WM"
    echo -e "  $c1 \$\$\;      Y\$b._   _,d\$P'      $WM_theme"
    echo -e "  $c1 Y\$\$.    $c2\`.$c1\`\"Y\$\$\$\$P\"'          $GTK_theme"
    echo -e "  $c1 \`\$\$b      $c2\"-.__               $GTK_icons"
    echo -e "  $c1  \`Y\$\$                         $GTK_font"
    echo -e "  $c1   \`Y\$\$."
    echo -e "  $c1     \`\$\$b."
    echo -e "  $c1       \`Y\$\$b."
    echo -e "  $c1          \`\"Y\$b._"
    echo -e "  $c1              \`\"\"\"\""$c0
  ;;

  "Crunchbang")
    [ -z $c1 ] && c1="\e[1;37m" # White
    "\e[1;30m" # Dark Gray
    echo -e "$c1                ___       ___      _"
    echo -e "$c1               /  /      /  /     | |"
    echo -e "$c1              /  /      /  /      | | $OS"
    echo -e "$c1             /  /      /  /       | | $kernel"
    echo -e "$c1     _______/  /______/  /______  | | $uptime"
    echo -e "$c1    /______   _______   _______/  | | $DE"
    echo -e "$c1          /  /      /  /          | | $WM"
    echo -e "$c1         /  /      /  /           | | $WM_theme"
    echo -e "$c1        /  /      /  /            | | $GTK_theme"
    echo -e "$c1 ______/  /______/  /______       | | $GTK_icons"
    echo -e "$c1/_____   _______   _______/       | | $GTK_font"
    echo -e "$c1     /  /      /  /               |_|"
    echo -e "$c1    /  /      /  /                 _"
    echo -e "$c1   /  /      /  /                 | |"
    echo -e "$c1  /__/      /__/                  |_|"$c0
  ;;

  "Gentoo")
    [ -z $c1 ] && c1="\e[1;37m" # White
    c2="\e[1;35m" # Light Purple
    echo -e "$c2         -/oyddmdhs+:."
    echo -e "$c2     -o"$c1"dNMMMMMMMMNNmhy+"$c2"-\`"
    echo -e "$c2   -y"$c1"NMMMMMMMMMMMNNNmmdhy"$c2"+-"
    echo -e "$c2 \`o"$c1"mMMMMMMMMMMMMNmdmmmmddhhy"$c2"/\`       $OS"
    echo -e "$c2 om"$c1"MMMMMMMMMMMN"$c2"hhyyyo"$c1"hmdddhhhd"$c2"o\`     $kernel"
    echo -e "$c2.y"$c1"dMMMMMMMMMMd"$c2"hs++so/s"$c1"mdddhhhhdm"$c2"+\`   $uptime"
    echo -e "$c2 oy"$c1"hdmNMMMMMMMN"$c2"dyooy"$c1"dmddddhhhhyhN"$c2"d.  $DE"
    echo -e "$c2  :o"$c1"yhhdNNMMMMMMMNNNmmdddhhhhhyym"$c2"Mh  $WM"
    echo -e "$c2    .:"$c1"+sydNMMMMMNNNmmmdddhhhhhhmM"$c2"my  $WM_theme"
    echo -e "$c2       /m"$c1"MMMMMMNNNmmmdddhhhhhmMNh"$c2"s:  $GTK_theme"
    echo -e "$c2    \`o"$c1"NMMMMMMMNNNmmmddddhhdmMNhs"$c2"+\`   $GTK_icons"
    echo -e "$c2  \`s"$c1"NMMMMMMMMNNNmmmdddddmNMmhs"$c2"/.     $GTK_font"
    echo -e "$c2 /N"$c1"MMMMMMMMNNNNmmmdddmNMNdso"$c2":\`"
    echo -e "$c2+M"$c1"MMMMMMNNNNNmmmmdmNMNdso"$c2"/-"
    echo -e "$c2yM"$c1"MNNNNNNNmmmmmNNMmhs+/"$c2"-\`"
    echo -e "$c2/h"$c1"MMNNNNNNNNMNdhs++/"$c2"-\`"
    echo -e "$c2\`/"$c1"ohdmmddhys+++/:"$c2".\`"
    echo -e "$c2  \`-//////:--."$c0
  ;;

  "Fedora")
    [ -z $c1 ] && c1="\e[1;37m" # White
    c2="\e[1;34m" # Light Blue
    echo -e "$c2           :/------------://"
    echo -e "$c2        :------------------://"
    echo -e "$c2      :-----------"$c1"/shhdhyo/"$c2"-://"
    echo -e "$c2    /-----------"$c1"omMMMNNNMMMd/"$c2"-:/"
    echo -e "$c2   :-----------"$c1"sMMMdo:/"$c2"       -:/    $OS"
    echo -e "$c2  :-----------"$c1":MMMd"$c2"-------    --:/   $kernel"
    echo -e "$c2  /-----------"$c1":MMMy"$c2"-------    ---/   $uptime"
    echo -e "$c2 :------    --"$c1"/+MMMh/"$c2"--        ---:  $DE"
    echo -e "$c2 :---     "$c1"oNMMMMMMMMMNho"$c2"     -----:  $WM"
    echo -e "$c2 :--      "$c1"+shhhMMMmhhy++"$c2"   ------:   $WM_theme"
    echo -e "$c2 :-      -----"$c1":MMMy"$c2"--------------/   $GTK_theme"
    echo -e "$c2 :-     ------"$c1"/MMMy"$c2"-------------:    $GTK_icons"
    echo -e "$c2 :-      ----"$c1"/hMMM+"$c2"------------:     $GTK_font"
    echo -e "$c2 :--"$c1":dMMNdhhdNMMNo"$c2"-----------:"
    echo -e "$c2 :---"$c1":sdNMMMMNds:"$c2"----------:"
    echo -e "$c2 :------"$c1":://:"$c2"-----------://"
    echo -e "$c2 :--------------------://"$c0
  ;;

  "BSD")
    [ -z $c1 ] && c1="\e[1;37m" # White
    c2="\e[1;31m" # Light Red
    echo -e "$c2              ,        ,"
    echo -e "$c2             /(        )\`"
    echo -e "$c2             \ \___   / |"
    echo -e "$c2             /- "$c1"_$c2  \`-/  '"
    echo -e "$c2            ($c1/\/ \ $c2\   /\\"
    echo -e "$c1            / /   |$c2 \`    \\     $OS"
    echo -e "$c1            O O   )$c2 /    |     $kernel"
    echo -e "$c1            \`-^--'\`$c2<     '     $uptime"
    echo -e "$c2           (_.)  _  )   /      $DE"
    echo -e "$c2            \`.___/\`    /       $WM"
    echo -e "$c2              \`-----' /        $WM_theme"
    echo -e "$c1 <----.     "$c2"__/ __   \\         $GTK_theme"
    echo -e "$c1 <----|===="$c2"O}}}$c1==$c2} \} \/$c1====   $GTK_icons"
    echo -e "$c1 <----'    $c2\`--' \`.__,' \\       $GTK_font"
    echo -e "$c2              |        |"
    echo -e "$c2               \       /       /\\"
    echo -e "$c2          ______( (_  / \______/"
    echo -e "$c2        ,'  ,-----'   |"
    echo -e "$c2        \`--{__________)"$c0
  ;;

  "Mandriva"|"Mandrake")
    c1="\e[1;34m" # Light Blue
    c2="\e[1;33m" # Bold Yellow
    echo -e "$c2                            \`\`"
    echo -e "$c2                           \`-."
    echo -e "$c1          \`               $c2.---"
    echo -e "$c1        -/               $c2-::--\`"
    echo -e "$c1      \`++    $c2\`----...\`\`\`-:::::.               $OS"
    echo -e "$c1     \`os.      $c2.::::::::::::::-\`\`\`     \`  \`   $kernel"
    echo -e "$c1     +s+         $c2.::::::::::::::::---...--\`   $uptime"
    echo -e "$c1    -ss:          $c2\`-::::::::::::::::-.\`\`.\`\`   $DE"
    echo -e "$c1    /ss-           $c2.::::::::::::-.\`\`   \`      $WM"
    echo -e "$c1    +ss:          $c2.::::::::::::-              $WM_theme"
    echo -e "$c1    /sso         $c2.::::::-::::::-              $GTK_theme"
    echo -e "$c1    .sss/       $c2-:::-.\`   .:::::              $GTK_icons"
    echo -e "$c1     /sss+.    $c2..\`$c1  \`--\`    $c2.:::              $GTK_font"
    echo -e "$c1      -ossso+/:://+/-\`        $c2.:\`"
    echo -e "$c1        -/+ooo+/-.              $c2\`"$c0
  ;;

  "Red Hat Linux")
    [ -z $c1 ] && c1="\e[1;37m" # White
    c2="\e[1;31m" # Light Red
    echo -e "$c2              \`.-..........\`"
    echo -e "$c2             \`////////::.\`-/."
    echo -e "$c2             -: ....-////////."
    echo -e "$c2             //:-::///////////\`             $OS"
    echo -e "$c2      \`--::: \`-://////////////:             $kernel"
    echo -e "$c2      //////-    \`\`.-:///////// .\`          $uptime"
    echo -e "$c2      \`://////:-.\`    :///////::///:\`       $DE"
    echo -e "$c2        .-/////////:---/////////////:       $WM"
    echo -e "$c2           .-://////////////////////.       $WM_theme"
    echo -e "$c1          yMN+\`.-$c2::///////////////-\`        $GTK_theme"
    echo -e "$c1       .-\`:NMMNMs\`  \`..-------..\`           $GTK_icons"
    echo -e "$c1        MN+/mMMMMMhoooyysshsss              $GTK_font"
    echo -e "$c1 MMM    MMMMMMMMMMMMMMyyddMMM+"
    echo -e "$c1  MMMM   MMMMMMMMMMMMMNdyNMMh\`     hyhMMM"
    echo -e "$c1   MMMMMMMMMMMMMMMMyoNNNMMM+.   MMMMMMMM "
    echo -e "$c1    MMNMMMNNMMMMMNM+ mhsMNyyyyMNMMMMsMM  "$c0
  ;;

  *)
    [ -z $c1 ] && c1="\e[1;37m" # White
    c2="\e[1;30m" # Light Gray
    c3="\e[1;33m" # Light Yellow
    echo " "
    echo " "
    echo -e "$c2         #####"
    echo -e "$c2        #######"
    echo -e "$c2        ##"$c1"O$c2#"$c1"O$c2##             $OS"
    echo -e "$c2        #$c3#####$c2#             $kernel"
    echo -e "$c2      ##$c1##$c3###$c1##$c2##           $uptime"
    echo -e "$c2     #$c1##########$c2##          $DE"
    echo -e "$c2    #$c1############$c2##         $WM"
    echo -e "$c2    #$c1############$c2###        $WM_theme"
    echo -e "$c3   ##$c2#$c1###########$c2##$c3#        $GTK_theme"
    echo -e "$c3 ######$c2#$c1#######$c2#$c3######      $GTK_icons"
    echo -e "$c3 #######$c2#$c1#####$c2#$c3#######      $GTK_font"
    echo -e "$c3   #####$c2#######$c3#####"$c0
    echo " "
    echo " "
    echo " "
  ;;
esac
}

infoDisplay () {
  if [ -z "$textcolor" ]; then textcolor="\e[0m"; fi
  if [ -z "$labelcolor" ]; then
    case $distro in
      "Arch Linux"|"Fedora"|"Mandriva"|"Mandrake") labelcolor="\e[1;34m";;
      "Linux Mint") labelcolor="\e[1;32m";;
      "Ubuntu"|"Debian"|"BSD"|"Red Hat Linux") labelcolor="\e[1;31m";;
      "Crunchbang") labelcolor="\e[1;30m";;
      "Gentoo") labelcolor="\e[1;35m";;
      *) labelcolor="\e[1;33m";;
    esac
  fi
  sysArch=`uname -m`
  OS="$labelcolor OS:$textcolor $distro $sysArch"
  kernel="$labelcolor Kernel:$textcolor $kernel"
  uptime="$labelcolor Uptime:$textcolor $uptime"
  DE="$labelcolor DE:$textcolor $DE"
  WM="$labelcolor WM:$textcolor $WM"
  WM_theme="$labelcolor WM Theme:$textcolor $Win_theme"
  GTK_theme="$labelcolor GTK Theme:$textcolor $gtkTheme"
  GTK_icons="$labelcolor Icon Theme:$textcolor $gtkIcons"
  GTK_font="$labelcolor Font:$textcolor $gtkFont"
  if [[ "$display" =~ "ASCII" ]]; then 
    asciiText
  else
    echo -e "$OS" 
    echo -e "$kernel"
    echo -e "$uptime"
    echo -e "$DE"
    echo -e "$WM"
    echo -e "$WM_theme"
    echo -e "$GTK_theme"
    echo -e "$GTK_icons"
    echo -e "$GTK_font"
  fi
}

##################
# Let's Do This!
##################

[[ "$display" =~ "OS" ]] && detectdistro
[[ "$display" =~ "Kernel" ]] && detectkernel
[[ "$display" =~ "Uptime" ]] && detectuptime
[[ "$display" =~ "DE" ]] && detectde
[[ "$display" =~ "WM" ]] && detectwm
[[ "$display" =~ "Win_theme" ]] && detectwmtheme
[[ "$display" =~ "Theme" ]] && detectgtk
infoDisplay
[ "$screenshot" -eq "1" ] && takeShot
