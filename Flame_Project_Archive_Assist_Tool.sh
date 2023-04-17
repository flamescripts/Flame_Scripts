#!/bin/bash
#
## 04/17/23
##
## Name: Flame Project Archive Assist Tool
## Desc: Basic tool that will read the project list as seen by flame_archive and create/append
## archives based on user input.  Archives and supporting files are placed in individual folders
## based on the Flame project name.  Projects processed in succession.
##
##
## Always Current Version:
##      https://github.com/flamescripts/Flame_Scripts
##
## Disclaimer: This is not an official Autodesk certified script.  Neither the
## author nor Autodesk are responsible for any use, misuse, unintended results
## or data loss that may occur from using this script.  This has not been
## thoroughly tested and is a work in progress.  This was created to address a
## specific customer issue and may not be applicable to your workflow.
##
## Use at your own risk.  Script intended for providing guidance only.
## There is no support provided.  Caution is strongly advised.
##
## Test OS: macOS 12.6.2, 13.3.1 & Rocky 8.5
##
## USAGE: The variable 'ARCHIVEPATH' must be changed to avoid filling up a system
## drive.  Verify there is adequate space available on the destination.
##
## flame_archive is set to current version and can be set to a specific
## version by editing value in 'BINARY'.
##
##########################################################################

## CUSTOMIZABLE VARIABLES
ARCHIVEPATH="/var/tmp/BACKUP TEST"
BINARY=/opt/Autodesk/io/bin/flame_archive

## TYPESETTING & RESET CONSOLE
bold=$(tput bold)
underline=$(tput smul)
normal=$(tput sgr0)
clear

## CHECK IF FLAME FAMILY IS IN SESSION
if /usr/bin/pgrep -x "flame" > /dev/null; then
    echo -e "Flame is in session\nPlease ${bold}EXIT${normal} the application before continuing\n\n";exit
elif /usr/bin/pgrep -x "flameassist" > /dev/null; then
    echo -e "Flame Assist is in session\nPlease ${bold}EXIT${normal} the application before continuing\n\n";exit
elif /usr/bin/pgrep -x "flare" > /dev/null; then
    echo -e "Flare is in session\nPlease ${bold}EXIT${normal} the application before continuing\n\n";exit
else
    echo -e "Flame Project Archive Assist Tool will query your Flame projects and present options for archiving the project."
    echo -e "\nPlease allow time to load the project listing.\n";

    ## HOUSEKEEPING
    if [ ! -f "$ARCHIVEPATH" ]; then
      mkdir -m 777 -p "$ARCHIVEPATH"
    fi
    truncate -s 0 "$ARCHIVEPATH/_projectlist.txt"

    ## GATHER PROJECT LIST
    $BINARY -l | awk '/Projects/{ f = 1; next } /Stopping/{ f = 0 } f' > "$ARCHIVEPATH/_projectlist.txt"

    ## SELECT PROJECT TO ARCHIVE FROM PROJECT LIST
    while read -r -u 3 FLAMEPROJECT; do
      echo "Do you want to Archive the ${bold}${underline}$FLAMEPROJECT${normal} Flame project?:"
      read -n 1 -r -p "${bold}Y${normal} for Yes, ${bold}N${normal} for No: " CONT
          if [[ $CONT =~ ^[Yy]$ ]]; then
          clear
          ## CHECK IF ARCHIVE EXISTS AND CREATE CONTAINER IF NOT
          echo "Checking if existing Flame archive exists for ${bold}$FLAMEPROJECT${normal}."
          ARCHIVEFILE="$ARCHIVEPATH/$FLAMEPROJECT"
          if [ -f "$ARCHIVEFILE/$FLAMEPROJECT" ]; then
            echo -e "Using the existing Flame archive: $ARCHIVEFILE\n";
          else
            echo -e "An archive of ${bold}${underline}$FLAMEPROJECT${normal} does not exist in the specified destination."
            echo -e "\n\nCreating that archive now...\n\n"
            mkdir -m 777 -p "$ARCHIVEFILE/"
            $BINARY -f -F "$ARCHIVEFILE/$FLAMEPROJECT"
          fi

          ## SELECT DESIRED ARCHIVreE TYPE
          echo -e "\nPlease choose from the following options to complete the ${bold}${underline}$FLAMEPROJECT${normal} archive:"
          echo "  Enter ${bold}(A)${normal} to Archive/Append to an ${bold}\"Normal\"${normal} archive."
          echo "  Enter ${bold}(C)${normal} to Archive/Append to an ${bold}\"Compact\"${normal} archive."
          echo "  Enter ${bold}(O)${normal} to Archive/Append ${bold}Omitting${normal} sources,renders,maps and unused from archive."
          echo "  Enter ${bold}(S)${normal} to ${bold}Skip${normal} this project and continue to the next project."
          echo -e "  Enter ${bold}(Q)${normal} to ${bold}Quit this script${normal}.\n"

          while true; do
            read -r -n 1 ARCHIVESELECTION
            case $ARCHIVESELECTION in

              [Aa]* )
                echo -e " was selected: Archiving project $FLAMEPROJECT - Normal Archive\n\n"
                $BINARY -a -P "$FLAMEPROJECT" -F "$ARCHIVEFILE/$FLAMEPROJECT" -N
                echo -e "\n\n"
                read -n 1 -s -r -p "Process complete.  Please review the information above.  Then press any key to continue."
                break
              ;;

              [Cc]* )
                echo -e " was selected: Archiving project $FLAMEPROJECT - Compact Archive\n\n"
                $BINARY -a -P "$FLAMEPROJECT" -F "$ARCHIVEFILE/$FLAMEPROJECT"
                echo -e "\n\n"
                read -n 1 -s -r -p "Process complete.  Please review the information above.  Then press any key to continue."
                break
              ;;

              [Oo]* )
                echo -e " was selected: Archiving project $FLAMEPROJECT - omiting sources, renders, maps and unused\n\n"
                $BINARY -a -P "$FLAMEPROJECT" -F "$ARCHIVEFILE/$FLAMEPROJECT" -k -O renders,sources,unused,maps
                echo -e "\n\n"
                read -n 1 -s -r -p "Process complete.  Please review the information above.  Then press any key to continue."
                break
              ;;

              [Ss]* )
                clear
                echo "S was selected: Skipping archival of Flame project: $FLAMEPROJECT"
                echo
                sleep .5;break
              ;;

              [Qq]* )
                echo " Script Exiting."
                exit 0
              ;;

              *)
                clear
                echo -e "${bold}Invalid option${normal}: $ARCHIVESELECTION key."
                echo -e "\nPlease choose from the following options to complete the ${bold}${underline}$FLAMEPROJECT${normal} archive:"
                echo "  Enter ${bold}(A)${normal} to Archive/Append to an ${bold}\"Normal\"${normal} archive."
                echo "  Enter ${bold}(C)${normal} to Archive/Append to an ${bold}\"Compact\"${normal} archive."
                echo "  Enter ${bold}(O)${normal} to Archive/Append ${bold}Omitting${normal} sources,renders,maps and unused from archive."
                echo "  Enter ${bold}(S)${normal} to ${bold}Skip${normal} this project and continue to the next project."
                echo -e "  Enter ${bold}(Q)${normal} to ${bold}Quit this script${normal}.\n"
              ;;
            esac
          done
          clear;
        elif [[ $CONT =~ ^[Nn]$ ]]; then
          clear
          echo "Skipping archival of Flame project: $FLAMEPROJECT";sleep 1.5;clear
        else
          clear
          echo "Invalid input Detected- Script Exiting For Safety"; exit
        fi
    done 3< "$ARCHIVEPATH/_projectlist.txt"
fi
## GOODBYE
echo -e "Script exiting.\nThank you for using the Flame Project Archive Assist Tool"
exit
