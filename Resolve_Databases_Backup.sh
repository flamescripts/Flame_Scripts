#!/bin/bash
#  Davinci Resolve postgres database backup for use with macOS.
#  Postgres passwords need to be stored in user ~/.pgpass
#
#  DBnames is in line wth DBips 1:1 2:2 etc.
#  Usage: 
#     DBnames=('name_of_dbase1' 'name_of_dbase2' 'name_of_dbase3')
#     DBips=('ip_for_dbase1' 'ip_for_dbase2' 'ip_for_dbase3')
#
#  Author not responsible for any data loss from use.
#  Do not use unless you understand every command and it's risk.
#  Data loss possible.

# Arrays and Variables
DBnames=('pub_db_2020' 'mv_db_2020' 'comm_db_2020')
DBips=('10.10.99.20' '10.10.99.20' '10.10.99.23')

BUpath=/TESTSAN/BEAU/_Scripts
BUdatabases=/TESTSAN/BEAU/_Scripts/Database_Backups
RSYNCpath=/Volumes/ResolveData/Backups/Postgres_DB
RSYNCorphans=/Volumes/ResolveData/Backups/Postgres_DB_orphans
NOerrors=0

# Clear temp file from previous sessions
dd if=/dev/null of=$BUpath/backup_debug.tmp
clear

# First check if postgres is running on ip, then Optimize database, then backup and compress database
echo "Checking Database Availability"
echo

for db in ${!DBnames[@]};
do
	DBip=${DBips[$db]}
	DBname=${DBnames[$db]}
	DBtaskcurrent=$((db+1))
	DBtasktotal=$((${#DBnames[@]}+1))
	DBbacknum=$(ls -1t $BUdatabases | grep $DBname | grep $DBip | wc -l)

	#Tally processes and report current task
	echo "Processing Job $DBtaskcurrent of $DBtasktotal: Checking Database: ${DBname} on IP: ${DBip}"

	# This should have tighter conditionals.
	if /Library/PostgreSQL/12/bin/pg_isready -d postgres://${DBip}:5432/template;
	then
		# DB Online, Log Event and Proceed
		echo -e "`logger -p user.debug -s -t "${DBip} > ${DBname}: Online " "DaVinci Resolve Database Backup Started" 2>&1 | tee -a $BUpath/backup_debug.tmp`"

		# Maintanance and backup of postgres
#		/Library/PostgreSQL/12/bin/reindexdb --host ${DBip} --username postgres ${DBname} --no-password --echo &>/dev/null
#		/Library/PostgreSQL/12/bin/vacuumdb --analyze --host ${DBip} --username postgres ${DBname} --verbose --no-password &>/dev/null
#		/Library/PostgreSQL/12/bin/pg_dump --host ${DBip} --username postgres ${DBname} --blobs --file $BUdatabases/Resolve_${DBname}_${DBip}_$(date +'%m-%d-%Y_%H-%M')_PostgreSQL_db.backup --verbose --format=custom --compress=9 --no-password &>/dev/null

		# Log backup for that IP/DB pair
		echo -e "`logger -p user.debug -s -t "${DBip} > ${DBname}: Online " "DaVinci Resolve Database Backup Completed" 2>&1 | tee -a $BUpath/backup_debug.tmp`"

		# If 3 versions exits of backup, remove oldest backup keep disk usage in-check
		if [ "$DBbacknum" -gt 4 ];
		then
			echo "Rollover: Removing oldest backups of ${DBip}:${DBname} > `ls -1t $BUdatabases | grep Resolve_${DBname}_${DBip}_ | tail -n 1` "

			echo "Deleted Backups:"
			ls -1t $BUdatabases | grep Resolve_${DBname}_${DBip}_ | tail -n +4
			cd $BUdatabases ; ls -t $BUdatabases | grep Resolve_${DBname}_${DBip}_ | tail -n +4 | xargs rm --
			echo "Remaining Backups:"
			ls -1t $BUdatabases | grep Resolve_${DBname}_${DBip}_
		else
			echo "Rollover: Unable to remove oldest backup of ${DBip}:${DBname} > Not enough backups available, skipping removal"
			echo "Remaining Backups:"
			ls -1t $BUdatabases | grep Resolve_${DBname}_${DBip}_
		fi
		echo
		else
			# DB Offline, Log Event and Proceed
			echo -e "*** `logger -p user.error -s -t "${DBip} > {DBname}: OFF-LINE ERROR " "DaVinci Resolve Database Backup Skipped" 2>&1 | tee -a $BUpath/backup_debug.tmp`"
			echo
			NOerrors=$((NOerrors+1))
		fi
		done

# Check if network share is available, if available rsync local backup to share
	echo "Processing Job $DBtasktotal of $DBtasktotal: Checking Network Share Availability and Backing up the Backups"


if [ -d "$RSYNCpath" ];
then
	echo -e "`logger -p user.debug -s -t "$RSYNCpath > Share Online" "House Keeping: Rsync Started" 2>&1 | tee -a $BUpath/backup_debug.tmp`"
	rsync -e 'ssh -c arcfour' --ignore-errors -rltgoDv --ignore-errors --stats --progress --delete --backup --backup-dir="$RSYNCorphans/$(date +\%m-\%d-\%Y)" --prune-empty-dirs $BUdatabases/ $RSYNCpath/ | tail -n 2 | head -n 10
	echo -e "`logger -p user.debug -s -t "$RSYNCpath > Share Online" "House Keeping: Rsync Completed" 2>&1 | tee -a $BUpath/backup_debug.tmp`"
	echo
else
	echo -e "*** `logger -p user.error -s -t "$RSYNCpath > SHARE OFFLINE ERROR " "House Keeping: Rsync Unavailable" 2>&1 | tee -a $BUpath/backup_debug.tmp`"
	echo
	NOerrors=$((NOerrors+1))
fi

# Log session
cat $BUpath/backup_debug.tmp | sed 's/\\033\[[0-9;]*[JKmsu]//g' >> $BUpath/backup_resolve_db_script.log

# Bye

if [ ${NOerrors}  -eq 0 ];
        then
		echo "Script Completed with $NOerrors errors"
                echo
        else
		echo "Script Completed."  
		echo "# of Errors detected: $NOerrors"
		echo
		exit 1
fi
exit 0
