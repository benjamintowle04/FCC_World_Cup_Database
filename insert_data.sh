#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#Function to find a team in the database, then insert it if the team is not found
find_and_insert_team() {
  local NAME=$1

  #get team_id from winner
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$NAME'")

  #if not found
  if [[ -z $TEAM_ID ]]
  then
    # insert team into db
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$NAME')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into teams, $NAME
    fi

  fi
}

#Function to retrieve the team_id from the name of the winner/loser
get_team_id() {
  local NAME=$1

  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$NAME'")

  #if not found
  if [[ -z $TEAM_ID ]] 
  then 
    echo ERROR! Could not find team

  else 
    echo $TEAM_ID
  fi

}


echo $($PSQL "TRUNCATE games, teams")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]] 
    then
      #find/insert winner
      find_and_insert_team "$WINNER"

      #find/insert opponent
      find_and_insert_team "$OPPONENT"

    fi
  
done



cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  GAME_ID=0
  if [[ $YEAR != "year" ]] 
    then

      #Get winner ID
      WINNER_ID=$(get_team_id "$WINNER")

      #Get loser ID
      OPPONENT_ID=$(get_team_id "$OPPONENT")


      # Insert game
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES('$YEAR', '$ROUND', '$WINNER_GOALS', '$OPPONENT_GOALS', '$WINNER_ID', '$OPPONENT_ID')")
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into games
      fi

    fi

    GAME_ID=$GAME_ID+1
  
done