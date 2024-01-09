#!/bin/bash
#
## 06/15/22
##
## Name: Flame_Basic_Archive.sh
## Desc: Script to create ande append Flame archive based on project name
##
## Always Current Version:
##      https://github.com/flamescripts/Flame_Scripts
##
## Disclamer: This is not an official Autodesk certified script.  Neither the
## author nor Autodesk are responsible for any use, misuse, unintened results
## or data loss that may ocurr from using this script.  This has not been
## thoroughly tested and is a work in progress.  This was created to address a
## specific customer issue.
##
## Use at your own risk.  Script intended for providing guidance only.
##
## Test OS: macOS 12.4
##
## USAGE: Edit values in PROJECTNAME and ARCHIVEPATH to the Flame project name
## as listed by "flame_archive -l" and desited backup location.  Integrate with
## a nightly task list.
##
##########################################################################

# CHANGE THESE
#############################
PROJECTNAME=FlameTest
ARCHIVEPATH=/var/tmp/TEST_ARC2
###############################


ARCHIVEFILE=$ARCHIVEPATH/$PROJECTNAME

# Check if Flame is running

if pgrep -x "flame" > /dev/null
then
    clear
    echo "Flame is Running"
    echo "Please Exit Flame before Continuing"
    exit
else

    # Check if Archive exists and Create container if not
    if [ -f "$ARCHIVEFILE" ]; then
        echo "Using existing $ARCHIVEFILE"
    else
        echo "$ARCHIVEFILE does not exist, creating."
        mkdir -m 777 -p $ARCHIVEPATH
        /opt/Autodesk/io/bin/flame_archive -f -F $ARCHIVEFILE
    fi

    #Append Project to Archive
    /opt/Autodesk/io/bin/flame_archive -a -P $PROJECTNAME -F $ARCHIVEFILE
fi
exit
