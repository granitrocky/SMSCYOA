#!/bin/bash

playerID=$1
choice=`echo $2 | tr '[a-z]' '[A-Z]'`

progress=`sqlite3 playerdb/playerdb "select progress from players where playerID='$playerID';"`
seen=`sqlite3 playerdb/playerdb "select seen from players where playerID='$playerID';"`
if [ $seen -eq 0 ]; then
	source $progress
	echo $Text
	`sqlite3 playerdb/playerdb "update players SET seen='1' WHERE playerID='$playerID';"`
else
	source $progress
	declare -a Opts=$Opts
	HELP=("${Opts[@]} Resend")
	RESEND="Placeholder"
	if [ "${!choice}" = "" ]; then
		echo "Command not recognized. Please enter a valid command or text 'Help' for options"
	else
		if [ "$choice" = "HELP" -o "$choice" = "RESEND" ]; then
			if [ "$choice" = "HELP" ]; then echo 'Possible Actions: '"${HELP[@]}"; fi
			if [ "$choice" = "RESEND" ]; then `sqlite3 playerdb/playerdb "update players SET seen='0' WHERE playerID='$playerID';"`; fi
		else
			`sqlite3 playerdb/playerdb "update players SET progress='${!choice}' WHERE playerID='$playerID';"`
			`sqlite3 playerdb/playerdb "update players SET seen='0' WHERE playerID='$playerID';"`
		fi	
	fi
fi
