#!/bin/bash
## 08/27/20
##
## Name: CentOS_Wacom_Orientation.sh
## Desc: Some love for the lefties
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
## IMPORTANT:  If using script remotely via ssh, be sure to export the DISPLAY
## ex: export DISPLAY=:0
##
## Installation:
## 1) Create "Wacom-Hands" folder in /opt/Autodesk.
## 2) Download and Copy 'CentOS_Wacom_Orientation.sh' to /opt/Autodesk/Wacom-Hands/'
## 3) Download and Copy 'CentOS_Wacom_Orientation.png' to /opt/Autodesk/Wacom-Hands/'.
## 4) Download and Copy 'CentOS_Wacom_Orientation.desktop' to Flame User's Desktop.
##
##  NOTE:
##    If you place the files in a folder other than '/opt/Autodesk/Wacom-Hands/',
##    you must update the following 2 lines in "CentOS_Wacom_Orientation.desktop" or 
##    this script will break.
## --   EXAMPLE: Exec='/opt/Autodesk/Wacom-Hands/CentOS_Wacom_Orientation.sh'
## --   EXAMPLE: Icon='/opt/Autodesk/Wacom-Hands/CentOS_Wacom_Orientation.png'
##
## Usage:
##
## Double Click the hands icons named Wacom Orientation on Flame User's Desktop.
## --Select 1 for Left-Handed Orientation
## --Select 2 for Right-Handed orientation
##
##########################################################################


# Variables
STYLUS=`xsetwacom --list devices | awk '/STYLUS/||/stylus/||/Stylus/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`


# SSH DISPLAY
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        clear
        echo "It looks like you are using a remote shell, this script should be modified if you are automating to remove interactive portion."
        echo "You MUST also export display if errors occur: '${bold}export DISPLAY=:0'"
        read -n 1 -s -r -p "Press any key to continue"
fi

# Reset console
clear


# Model IDs and current Rotation setting

echo 'CentOS Wacom table orientation script'
echo 'STYLUS:' $STYLUS
echo ''
echo 'Tablet rotation is currently set to:' `xsetwacom get "$STYLUS" rotate`
echo ''


## Select Orientation
echo ''
echo "Enter (1) if you are Left-handed or Enter (2) if you are Right-Handed or Enter (3) to Exit w/out changing orientation"
echo ''
select hand in Left-Handed Right-Handed Quit; do
  case $hand in

    Left-Handed)
	echo ''
	echo 'Switching to Left Handed orientation'
	xsetwacom set "$STYLUS" rotate half
	break
      ;;

    Right-Handed)
	echo ''
	echo 'Switching to Right Handed orientation'
	xsetwacom set "$STYLUS" rotate none
	break
	;;

    Quit)
	echo 'Quiting, no changes made.'
	break
	;;
    *) 
	echo ''
	echo "Invalid option $REPLY, Please select a number between 1 and 3"
      ;;
  esac
done
