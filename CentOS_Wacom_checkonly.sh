#!/bin/bash
## 05/16/19
##
## Name: CentOS_Wacom_checkonly.sh
## Desc: Very sloppy method to list current Wacom settings for use
## Update CentOS_Wacom_fix.sh.  WIP
##
## Always Current Version:
##      https://github.com/flamescripts/Flame_Scripts
##
## Disclamer: This is not an official Autodesk certified script.  I nor
## Autodesk are responsible for any use, misuse, unintened results or data
## loss that may ocurr from using this script.  Use at your own risk
## Intended for providing guidance only.
##
## Test Models: Intuos 4, Intuos Pro Medium, Intuos Pro Large, Intuos5 Touch Medium
## Test OS: Autodesk CentOS 7.2 ISO 1511 Rev 003 using ks.cfg
##
## IMPORTANT:  If using script remotely via ssh, be sure to export the DISPLAY
## ex: export DISPLAY=:0
##
##########################################################################


# Variables
PAD=`xsetwacom --list devices | awk '/PAD/||/pad/||/Pad/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
TOUCH=`xsetwacom --list devices | awk '/FINGER/||/finger/||/Finger/||/TOUCH/||/touch/||/Touch/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
STYLUS=`xsetwacom --list devices | awk '/STYLUS/||/stylus/||/Stylus/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
CURSOR=`xsetwacom --list devices | awk '/CURSOR/||/cursor/||/Cursor/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
ERASER=`xsetwacom --list devices | awk '/ERASER/||/eraser/||/Eraser/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
RING=( AbsWheelUp AbsWheelDown AbsWheel2Up AbsWheel2Down RelWheelUp RelWheelDown StripLeftUp StripLeftDown StripRightUp StripRightDown )

ZERO='button 0'
ZEROALT='0'


# SSH DISPLAY
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        clear
        echo "It looks like you are using a remote shell"
        echo "You MUST export display if errors occur: '${bold}export DISPLAY=:0'"
        read -n 1 -s -r -p "Press any key to continue"
fi


# Reset console
clear


# Model IDs for reference
echo 'CentOS_Wacom_checkonly script'
echo 'PAD:' $PAD
echo 'STYLUS:' $STYLUS
echo 'ERASER:' $ERASER
echo 'CURSOR:' $CURSOR

if [[ $TOUCH ]]; then
        echo 'TOUCH:' $TOUCH
        echo '  Touch is currently turned:' `xsetwacom get "$TOUCH" TOUCH`
        echo
else
        echo 'TOUCH: no touch feature detected on this Wacom tablet'
        echo
fi

# Verify changes correct for touch, ring and expresskeys
echo 'Checking Ring:'
for r in "${RING[@]}"
do
        echo "  *$r:"  `xsetwacom get "$PAD" "$r"`
done

echo
echo 'Checking ExpressKeys:'
for e in {1..3} {8..15}
do
        echo "  *ExpressKey #$e:" `xsetwacom get "$PAD" Button "$e"`
done

# Break for readability
echo
read -n 1 -s -r -p "Press any key to print remaining data"

xsetwacom -s get "$PAD" all
xsetwacom -s get "$TOUCH" all
xsetwacom -s get "$STYLUS" all
xsetwacom -s get "$ERASER" all
xsetwacom -s get "$CURSOR" all
libwacom-list-local-devices
xinput list "$PAD"
rpm -qa |grep -i wacom

echo
echo 'Script Complete'

# Goodbye
exit
