#!/bin/bash
## 01/30/19
##
## Name: CentOS_Wacom_fix.sh
## Desc: Disable Wacom Tablet gesture touch, touch ring and express buttons
## with minimal user interaction
##
## Always Current:
##	https://github.com/flamescripts/Flame_Scripts
##
## Disclamer: This is not an official Autodesk certified script.  I nor
## Autodesk are responsible for any use, misuse, unintened results or data
## loss that may ocurr from using this script.  Use at your own risk.
## Intended for providing guidance only.
##
## Test Models: Intuos Pro Medium (PTH-660) and Intuos5 Touch Medium (PTH-650)
## Test OS: Autodesk CentOS 7.2 ISO 1511 Rev 003 using ks.cfg
##
##########################################################################


# Variables
PAD=`xsetwacom --list devices | awk '/PAD/||/pad/||/Pad/' | awk -F "id:" '{print $1}' | cut -d " " -f1-6`
FINGER=`xsetwacom --list devices | awk '/FINGER/||/finger/||/Finger/' | awk -F "id:" '{print $1}' | cut -d " " -f1-6`
RING=( AbsWheelUp AbsWheelDown AbsWheel2Up AbsWheel2Down RelWheelUp RelWheelDown )
ZERO='button 0'
ZEROALT='0'

# Reset console
clear

# Model ID for reference
echo
echo 'Setting PAD:' $PAD
echo 'Setting FINGER:' $FINGER

# Turn off touch
echo
echo 'Turning touch off'
xsetwacom set "$FINGER" TOUCH off

# Verify changes correct for touch
echo '  Touch is currently turned:' `xsetwacom get "$FINGER" TOUCH`

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
