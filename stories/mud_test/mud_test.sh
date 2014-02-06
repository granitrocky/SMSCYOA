#!/bin/bash

playerID=$1
choice=`echo $2 | tr '[A-Z]' '[a-z]'`

source defaultvars

progress=`sqlite3 playerdb/playerdb "select progress from players where playerID='$playerID';"`
seen=`sqlite3 playerdb/playerdb "select seen from players where playerID='$playerID';"`
if [ -n "$choice" ]; then
	if [ -n "$(echo ${reserved_words} | gawk '$0 ~ /\y'$choice'\y/ {print}')" ]; then 
		`sqlite3 playerdb/playerdb "update players SET lastchoice='$2' WHERE playerID='$playerID';"`
	fi
else
	if [ -n "$(echo ${reserved_words} | gawk '$0 ~ /\y'$choice'\y/ {print}')" ]; then
		choice_wcase=`sqlite3 playerdb/playerdb "select lastchoice from players where playerID='$playerID';"`
		choice=`echo $choice_wcase | tr '[A-Z]' '[a-z]'`
	fi
fi

source functionfile

if [ -e "$(echo $progress | awk -F ' ' '{print $1}')" ]; then
	source $progress
else
	eval "$progress"
fi

if [ $seen -eq 0 ]; then
	echo $Text
	`sqlite3 playerdb/playerdb "update players SET seen='1' WHERE playerID='$playerID';"`
else
	help="$Opts"' <RESEND>'
	resend="Placeholder"
	if [ "${!choice}" = "" ]; then
		echo "Command not recognized. Please enter a valid command or text 'Help' for options"
	else
		if [ "$choice" = "help" -o "$choice" = "resend" ]; then
			if [ "$choice" = "help" ]; then echo 'Possible Actions: '"$HELP"; fi
			if [ "$choice" = "resend" ]; then `sqlite3 playerdb/playerdb "update players SET seen='0' WHERE playerID='$playerID';"`; fi
		else
			`sqlite3 playerdb/playerdb "update players SET progress='${!choice}' WHERE playerID='$playerID';"`
			`sqlite3 playerdb/playerdb "update players SET seen='0' WHERE playerID='$playerID';"`
		fi	
	fi
fi
