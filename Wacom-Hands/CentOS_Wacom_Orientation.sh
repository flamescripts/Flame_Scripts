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
## Changelist:
##    08/27/20: 1st version
##    07/01/21: Cleanup, added option to add and remove persistence and a help option
##
##########################################################################                                                                                                                                      
                                                                                                                                                                                                                
                                                                                                                                                                                                                
# Variables and Styles                                                                                                                                                                                                     
STYLUS=`xsetwacom --list devices | awk '/STYLUS/||/stylus/||/Stylus/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`                                                             
BOLD=$(tput bold)                                                                                                                                                                                               
REGULAR=$(tput sgr0)                                                                                                                                                                                            
                                                                                                                                                                                                                
# SSH DISPLAY                                                                                                                                                                                                   
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then                                                                                                                                                              
        clear                                                                                                                                                                                                   
        echo "It looks like you are using a ${BOLD}remote shell${REGULAR}, this script should be modified if you are automating to remove interactive portion."                                                 
        echo "You MUST also export display if errors occur: '${BOLD}export DISPLAY=:0${REGULAR}'"                                                                                                               
        echo ''                                                                                                                                                                                                 
        read -n 1 -s -r -p "Press any key to continue"                                                                                                                                                          
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
        echo "  Enter ${BOLD}(3)${REGULAR} to make current settings persistent on boot if previously"                                                                                                           
        echo "  Enter ${BOLD}(4)${REGULAR} to remove persistence on boot if previously enabled"                                                                                                                 
        echo "  Enter ${BOLD}(5)${REGULAR} to Exit w/out changing the current orientation"                                                                                                                      
        echo ''

select hand in Left-Handed Right-Handed Remove-Persistence Quit Help; do
  case $hand in 
 
    Left-Handed) 
        clear
        echo 'Switching to Left Handed orientation' 
        xsetwacom set "$STYLUS" rotate half
        echo "#!/bin/bash" > $HOME/.wacom_orientation.sh
        echo "xsetwacom set \"$STYLUS\" rotate half" >> $HOME/.wacom_orientation.sh
        echo ''
        echo "Tablet rotation is now set to: ${BOLD}`xsetwacom get "$STYLUS" rotate`${REGULAR}!"
        echo ''
      ;; 
 
    Right-Handed) 
        clear
        echo 'Switching to Right Handed orientation' 
        xsetwacom set "$STYLUS" rotate none 
        echo "#!/bin/bash" > $HOME/.wacom_orientation.sh
        echo "xsetwacom set \"$STYLUS\" rotate none" >> $HOME/.wacom_orientation.sh
        echo ''
        echo "Tablet rotation is now set to: ${BOLD}`xsetwacom get "$STYLUS" rotate`${REGULAR}!"
        echo ''
      ;;
 
    Remove-Persistence) 
        clear
        echo "Removing Persistense from $HOME/.cshrc" 
        sed -i '/wacom_orientation/d' $HOME/.cshrc
        echo ''
        break 
      ;; 

    Quit) 
        echo 'Quiting, no changes have been made.' 
        break 
      ;; 

    Help) 
        clear
        echo "Please choose from the following options:"
        echo "  Enter ${BOLD}(1)${REGULAR} if you are Left-handed"
        echo "  Enter ${BOLD}(2)${REGULAR} if you are Right-Handed"
        echo "  Enter ${BOLD}(3)${REGULAR} to make current settings persistent on boot if previously"
        echo "  Enter ${BOLD}(4)${REGULAR} to remove persistence on boot if previously enabled"
        echo "  Enter ${BOLD}(5)${REGULAR} to Exit w/out changing the current orientation"
        echo ''
      ;; 

    *)  
        clear
        echo "Invalid option: $REPLY"
        echo "Please choose from the following options:"
        echo "  Enter ${BOLD}(1)${REGULAR} if you are Left-handed"
        echo "  Enter ${BOLD}(2)${REGULAR} if you are Right-Handed"
        echo "  Enter ${BOLD}(3)${REGULAR} to make current settings persistent on boot if previously"
        echo "  Enter ${BOLD}(4)${REGULAR} to remove persistence on boot if previously enabled"
        echo "  Enter ${BOLD}(5)${REGULAR} to Exit w/out changing the current orientation"
      ;; 

  esac 

## Persistance Check?
read -p "Persist these chnages? [Y] or [N]: " -n 1 -r
echo ''
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]
then
        sed -i '/wacom_orientation/d' $HOME/.cshrc
        echo $HOME/.wacom_orientation.sh >> $HOME/.cshrc
        chmod +o $HOME/.wacom_orientation.sh
        echo "Tablet rotation is set as: ${BOLD}`xsetwacom get "$STYLUS" rotate`${REGULAR} and will persist for ${BOLD}`id -un`${REGULAR} until this script is ran again."
        echo ''
        break
else
        break
fi
done 
