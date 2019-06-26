#!/bin/bash
## 01/30/19
##
## Name: CentOS_Wacom_fix.sh
## Desc: Disable Wacom Multi-Touch, ExpressKeys and Finger Wheel
## with minimal user interaction
##
## Always Current Version:
##      https://github.com/flamescripts/Flame_Scripts
##
## Disclamer: This is not an official Autodesk certified script.  I nor
## Autodesk are responsible for any use, misuse, unintened results or data
## loss that may ocurr from using this script.  Use at your own risk.
## Intended for providing guidance only.
##
## Test Models: Intuos Pro Medium, Intuos Pro Large, Intuos5 Touch Medium
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

# Reset console
clear

# Model ID for reference
echo
echo 'PAD:   ' $PAD
echo 'STYLUS:' $STYLUS
echo 'ERASER:' $ERASER
echo 'CURSOR:' $CURSOR

# Turn off touch
if [[ $TOUCH ]]; then
        echo 'TOUCH: ' $TOUCH
        echo
        echo '  Touch is currently turned:' `xsetwacom get "$TOUCH" TOUCH`
        echo
        echo 'Turning touch off'
                xsetwacom set "$TOUCH" TOUCH off
else
        echo 'TOUCH:  no touch feature detected on this Wacom tablet'
        echo
fi


# Turn off ring
echo
echo 'Turning ring off'
for r in "${RING[@]}"
do
        xsetwacom set "$PAD" "$r" "$ZERO"
        # Verify changes correct for ring - Comment out to silence
        echo "  $r"  `xsetwacom get "$PAD" "$r"`
done

# Turn off expresskeys 1-3, 8-13
echo
echo 'Turning expresskeys off'
for e in {1..3} {8..13}
do
        xsetwacom set "$PAD" Button "$e" "$ZERO"
        #Verify changes correct for buttons  - Comment out to silence
        echo "  $e" `xsetwacom get "$PAD" Button "$e"`
done

echo
echo 'Script Complete'

# Goodbye
exit
