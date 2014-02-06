#!/bin/bash

while [ 1 -eq 1 ]; do
all_players=`sqlite3 players/playerdb "select * from players;"`
for player in $all_players; do
    # Parsing data (sqlite3 returns a pipe separated string)
    FName=`echo $player | awk '{split($0,a,"|"); print a[2]}'`
    LName=`echo $player | awk '{split($0,a,"|"); print a[3]}'`
    playerID=`echo $player | awk '{split($0,a,"|"); print a[4]}'`
    game=`echo $player | awk '{split($0,a,"|"); print a[5]}'`
    cd "stories/$game"
    storydb="playerdb/playerdb"
    seen=`sqlite3 $storydb "select seen from players where playerID='$playerID';"`
    if [ $seen -eq 0 ]; then
    	game_output=`"./$game.sh" "$playerID"`
 		../../scripts/sender.rb -n $playerID -m "$game_output"    
   fi
	cd ../../
done
all_texts=`cat scripts/texts`
if [ "$all_texts" != "" ]; then
	echo -ne "" > scripts/texts
	OIFS=$IFS
   IFS=";"
	for ROW in $all_texts; do    
	    choice=`echo $ROW | awk '{split($0,a,"|"); print a[1]}'`
	    playerID=`echo $ROW | awk '{split($0,a,"|"); print a[2]}'`    
	    game=`sqlite3 players/playerdb "select currentgame from players where cellnumber='$playerID';"`
	    cd "stories/$game"
	    game_output=`"./$game.sh" "$playerID" "$choice"`
	 	 ../../scripts/sender.rb -n $playerID -m "$game_output"
	 	 cd ../../
	done
	IFS=$OIFS
fi
sleep 1
done