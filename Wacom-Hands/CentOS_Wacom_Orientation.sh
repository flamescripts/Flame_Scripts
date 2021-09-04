#!/bin/bash  
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
## Script has only tested in CentOS 7.2, 7.4 and 7.6 ks versions from Flame
## System Requirements.  Since intended for multiple OS users on a system
## per request, orientation not active till login.  Script not needed for
## CentOS 8.x.  GUI solution in OS settings for user. Use at your own risk.
## Script intended for providing guidance only.  There may be better options
## available.
## 
## IMPORTANT:  This is meant to be run locally in the GUI by the end user.
##
## Installation:
##
##    Perform these actions as the OS Flame user, not root:
##
##    1) Create "Wacom-Hands" folder in /opt/Autodesk w/ open permissions initially.
##    --  sudo mkdir -m 777 /opt/Autodesk/Wacom-Hands
##    2) Download and Copy 'CentOS_Wacom_Orientation.sh' to /opt/Autodesk/Wacom-Hands/'.
##    3) Download and Copy 'CentOS_Wacom_Orientation.png' to /opt/Autodesk/Wacom-Hands/'.
##    4) Download and Copy 'CentOS_Wacom_Orientation.desktop' to any Flame OS user's Desktop
##       as needed.
##    5) Change permissions of the two files in Wacom-Hands
##    --  sudo chmod +x /opt/Autodesk/Wacom-Hands/CentOS_*
##    6) Refresh Desktop.
##    7) Double Click icon on the Desktop to run.
## 
##  NOTE: 
##    If you place the files in a folder other than '/opt/Autodesk/Wacom-Hands/', 
##    you must update the following 2 lines in "CentOS_Wacom_Orientation.desktop" or  
##    this script will break. 
##    --  EXAMPLE: Exec='/opt/Autodesk/Wacom-Hands/CentOS_Wacom_Orientation.sh' 
##    --  EXAMPLE: Icon='/opt/Autodesk/Wacom-Hands/CentOS_Wacom_Orientation.png' 
## 
## Usage:
##
##     Double Click the hands icon Wacom Orientation on Flame User's Desktop.
##     --  Select 1 if you are Left-handed or Upside-Down.
##     --  Select 2 if you are Right-Handed.
##     --  Select 3 to remove persistence on boot if previously enabled. 
##     --  Select 4 to Exit w/out changing the current orientation.
##
## Changelist:
##    08/27/20: 1st version
##    07/01/21: Cleanup, added option to add and remove persistence and a help option
##    09/03/21: Cleanup, added bash and zsh per request, tested multiple
##              systems and environments.
##
## Resources:
## 
##  https://raw.githubusercontent.com/flamescripts/Flame_Scripts/master/Wacom-Hands/CentOS_Wacom_Orientation.desktop
##  https://github.com/flamescripts/Flame_Scripts/raw/master/Wacom-Hands/CentOS_Wacom_Orientation.png
##  https://raw.githubusercontent.com/flamescripts/Flame_Scripts/master/Wacom-Hands/CentOS_Wacom_Orientation.sh
##
###################################################################################  
		  
		  
# Variables and Styles		  
STYLUS=`xsetwacom --list devices | awk '/STYLUS/||/stylus/||/Stylus/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'` 
BOLD=$(tput bold)    
REGULAR=$(tput sgr0) 

# Get the users SHELL for .bash_profile, .zshrc or .cshrc shell initialization files
if [ $SHELL = "/bin/zsh" ]; then
	INIT=.zshrc
elif [ $SHELL = "/bin/bash" ]; then
	INIT=.bash_profile
elif [ $SHELL = "/bin/tcsh" ]; then
	INIT=.cshrc
else
	echo "undefined"
	exit 1
fi

# SSH DISPLAY		
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then    
		clear		
		echo "It looks like you are using a ${BOLD}remote shell${REGULAR} that is a bad idea."
		echo ''      
		read -n 1 -s -r -p "Press any key to exit."
		clear
		exit 1
elif [ $EUID = 0 ]; then
		clear		
		echo "${BOLD}Do not run this as root.${REGULAR}"     
		echo ''      
		read -n 1 -s -r -p "Press any key to exit."
		clear
		exit 1
fi		
		  
# Reset console      
clear     
		  
# Model IDs and current Rotation setting   
echo 'CentOS Wacom table orientation script for the ' $STYLUS | rev | cut -c12- | rev  
echo 'Tablet rotation is currently set to:' `xsetwacom get "$STYLUS" rotate`
echo ''

## Get selection
		echo "Please choose from the following options:"
		echo "  Enter ${BOLD}(1)${REGULAR} if you are Left-handed"
		echo "  Enter ${BOLD}(2)${REGULAR} if you are Right-Handed"
		echo "  Enter ${BOLD}(3)${REGULAR} to remove persistence on boot if previously enabled"
		echo "  Enter ${BOLD}(4)${REGULAR} to Exit w/out changing the current orientation"
		echo ''

while true; do

	select hand in Left-Handed Right-Handed Remove-Persistence Quit; do

	case $hand in 

		Left-Handed) 
			clear
			echo 'Switching to Left Handed orientation' 
			xsetwacom set "$STYLUS" rotate half
			echo "#!/bin/bash" > $HOME/.wacom_orientation.sh
			echo "xsetwacom set \"$STYLUS\" rotate half" >> $HOME/.wacom_orientation.sh
			echo ''
			echo "Tablet rotation is now set to: ${BOLD}`xsetwacom get "$STYLUS" rotate`${REGULAR}!"
			chmod +x .wacom_orientation.sh
			break
		;; 
 
		Right-Handed) 
			clear
			echo 'Switching to Right Handed orientation' 
			xsetwacom set "$STYLUS" rotate none 
			echo "#!/bin/bash" > $HOME/.wacom_orientation.sh
			echo "xsetwacom set \"$STYLUS\" rotate none" >> $HOME/.wacom_orientation.sh
			echo ''
			echo "Tablet rotation is now set to: ${BOLD}`xsetwacom get "$STYLUS" rotate`${REGULAR}!"
			chmod +x .wacom_orientation.sh
			break
		;;

		Remove-Persistence) 
			clear
			echo "Backing up $HOME/$INIT"
			cp -pv $HOME/$INIT $HOME/$INIT.backup
			echo "Removing Persistense from $HOME/$INIT"
			sed -i "/wacom_orientation/d" $HOME/$INIT
			echo ''
			read -n 1 -s -r -p "Press any key to exit"
			exit 0
		;; 

		Quit) 
			clear
			echo "No changes have been made."
			read -n 1 -s -r -p "Press any key to quit."
			exit 0 
		;; 

		*)  
       			clear
			echo "Invalid option: $REPLY"
			echo ''
			echo "Please choose from the following options:"		 
			echo "  Enter ${BOLD}(1)${REGULAR} if you are Left-handed"		  
			echo "  Enter ${BOLD}(2)${REGULAR} if you are Right-Handed"		 
			echo "  Enter ${BOLD}(3)${REGULAR} to remove persistence on boot if previously enabled"
			echo "  Enter ${BOLD}(4)${REGULAR} to Exit w/out changing the current orientation"
			echo ''
		;; 

	esac 

done
## Persistance Check?
echo ''
echo ''

echo "Would you like the tablet rotation of ${BOLD}`xsetwacom get "$STYLUS" rotate`${REGULAR} to continue after reboot?"
read -p "Press ${BOLD}[Y]${REGULAR} for Yes or ${BOLD}[N]${REGULAR} for No: " -n 1 -r

echo ''
echo ''

if [[ $REPLY =~ ^[Yy]$ ]]
then
	clear
		echo "Backing up $HOME/$INIT"
		cp -pv $HOME/$INIT $HOME/$INIT.backup
		sed -i '/wacom_orientation/d' $HOME/$INIT
		echo $HOME/.wacom_orientation.sh >> $HOME/$INIT
		chmod +x $HOME/.wacom_orientation.sh
		echo "Tablet rotation is set as: ${BOLD}`xsetwacom get "$STYLUS" rotate`${REGULAR} and will persist for ${BOLD}`id -un`${REGULAR} until this persistance is removed (option 3)."
		echo ''
		read -n 1 -s -r -p "Press any key to exit"
		exit 0
else
		exit 0
fi
done
