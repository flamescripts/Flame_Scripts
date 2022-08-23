#!/bin/bash
## 08/23/22
##
## Name: FlameStrace.sh
## Desc: Basic automated strace script.
##
## Always Current Version:
##      https://github.com/flamescripts/Flame_Scripts
##
## Disclamer: This is not an official Autodesk certified script.  Neither the
## author nor Autodesk are responsible for any use, misuse, unintened results 
## or data loss that may ocurr from using this script.
##
## Use at your own risk.  Script intended for providing guidance only.
##
## Limited tested with: Rocky 8.5 ADSK KS.
##
## Usage: add to the root crontab w/ desired interval
## Ex: (*/5 * * * * /root/FlameStrace.sh)
##
##########################################################################


# If Flame is not launched, exit script and have a nice day.
while ! pgrep -x "flame" > /dev/null
do
    exit
done


# If strace is already launched exit, otherwise strace Flame and exit process when Flame exits.

if pgrep -x "strace" > /dev/null
then
    exit
else
    # Run strace on Flame pid until Flame exits
    while pgrep -x "flame" > /dev/null
    do
        strace -f -p $(pidof flame)
    done
fi

exit
