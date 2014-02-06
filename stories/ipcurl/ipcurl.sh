#!/bin/bash

playerID=$1
choice=`echo $2 | tr '[A-Z]' '[a-z]'`
seen=`sqlite3 playerdb/playerdb "select seen from players where playerID='$playerID';"`

if [ $seen -eq 0 ]; then
	echo $(curl `cat ip_automation`)
	`sqlite3 playerdb/playerdb "update players SET seen='1' WHERE playerID='$playerID';"`
else
	`sqlite3 playerdb/playerdb "update players SET seen='0' WHERE playerID='$playerID';"`
fi
