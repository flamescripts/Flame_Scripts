#!/bin/bash
#
# Quick Script to Create SFTP users.
# Unsafe w/ no error checking and
# insecure as hell.  Use chroot jails
# at minimum and common sense. Not for
# actual human consumption.
#
#######################################

## Setup
clear
echo 'Client SFTP User Generator'
echo ''

# Location
path='/mnt/Storage/___CLIENT_FTPS'
bupath='/mnt/SAN3/BACKUPS/CLIENT_FTPS'
ip=$(dig +short myip.opendns.com @resolver1.opendns.com)

## USER INPUT WITH CHECK
echo ''
read -p 'Hello, enter client login name (underscores for spaces): ' username

while getent passwd $username >/dev/null; do
        echo ''
        read -p 'Username is already in use. Please create unique usename:  ' username
done
echo ''
read -p 'Enter comment for this account:  ' comment
echo ''


## USER SETUP

useradd -g sftp_clients -s /sbin/nologin -m -d $path/$username $username -c "$comment"
group=$(id -gn $username)
chown root:root $path/$username
chmod 755 $path/$username
mkdir $path/$username/{Downloads,Uploads}
chown $username:$group $path/$username/{Downloads,Uploads}


## PASSWORD GENERATION
password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)
echo $password | passwd $username --stdin >/dev/null


## SAVE DATA TO NETWORK LOCATION
echo 'Username: ' $username > $bupath/$username.txt
echo 'Password: ' $password >> $bupath/$username.txt
echo 'Home: ' $path/$username >> $bupath/$username.txt
echo 'Group: ' $group >> $bupath/$username.txt
echo 'Comment: ' $comment >> $bupath/$username.txt
echo '' >> $bupath/$username.txt


## DATA FOR USER PASTE
#######clear
echo ''
echo 'Copy & Paste to Client Email'
echo ''
echo '#######################'
echo 'Username is: '$username
echo 'Password is: '$password
echo ''
echo 'IP Address is: '$ip
echo 'Protocol is: SFTP'
echo '#######################'
echo ''
echo 'Copy postings for review to user Home SFTP directory: '$path/$username/Downloads
echo ''
echo 'Comment: '$comment
echo ''
echo
echo 'Script Complete'

# Goodbye
exit
