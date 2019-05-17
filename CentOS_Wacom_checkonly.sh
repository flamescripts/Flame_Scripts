#!/bin/bash
## 05/16/19
##
## Name: CentOS_Wacom_checkonly.sh
## Desc: List current Wacom Multi-Touch, ExpressKeys and Finger Wheel
## settings for help with debug of Update CentOS_Wacom_fix.sh
##
## Always Current Version:
##      https://github.com/flamescripts/Flame_Scripts
##
## Disclamer: This is not an official Autodesk certified script.  I nor
## Autodesk are responsible for any use, misuse, unintened results or data
## loss that may ocurr from using this script.  Use at your own risk.
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
PAD=`xsetwacom --list devices | awk '/PAD/||/pad/||/Pad/' | awk -F "id:" '{print $1}' | cut -d " " -f1-5`
FINGER=`xsetwacom --list devices | awk '/FINGER/||/finger/||/Finger/' | awk -F "id:" '{print $1}' | cut -d " " -f1-6`
RING=( AbsWheelUp AbsWheelDown AbsWheel2Up AbsWheel2Down RelWheelUp RelWheelDown )

# Reset console
clear

# Model IDs for reference
echo
echo 'PAD:' $PAD


if [[ $FINGER ]]; then
        echo 'FINGER:' $FINGER
        echo '  Touch is currently turned:' `xsetwacom get "$FINGER" TOUCH`
        echo
else
        echo 'FINGER: no touch feature detected'
        echo
fi

# Verify changes correct for touch, ring and expresskeys
xsetwacom -s get "$PAD" all
echo
echo 'Checking ring:'
for r in "${RING[@]}"
do
        echo "  *$r"  `xsetwacom get "$PAD" "$r"`
done
echo

echo 'Checking expresskeys:'
for e in {1..13}
do
        echo "  *$e" `xsetwacom -s get "$PAD" Button "$e"`
done

echo
echo 'Script Complete'

# Goodbye
exit
