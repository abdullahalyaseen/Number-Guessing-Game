#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=guess_game -t --no-align -c"
GAME(){
  RANDOM_NUMBER=$((${RANDOM:0:2} + 1))
  echo Guess the secret number between 1 and 1000:
  NUMBER_OF_GUESSES=1
  while [[ $USER_GUESS != $RANDOM_NUMBER ]]
  do
    read USER_GUESS
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      if [[ $USER_GUESS > $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $USER_GUESS < $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      elif [[ $USER_GUESS == $RANDOM_NUMBER ]]
      then
        SAVE=$($PSQL "insert into games(user_id,guesses) values($1,$NUMBER_OF_GUESSES)")
        echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!
      fi
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
    fi
  done
  
}
echo Enter your username:
read USER_NAME
CHECK_USERNAME_RESULT=$($PSQL "select user_id,user_name,count(game_id),min(guesses) from users inner join games using(user_id) where user_name = '$USER_NAME' group by user_id")
if [[ -z $CHECK_USERNAME_RESULT ]]
then
  echo Welcome, $USER_NAME! It looks like this is your first time here.
 RANDOM_NUMBER=$((${RANDOM:0:2} + 1))
  echo Guess the secret number between 1 and 1000:
  NUMBER_OF_GUESSES=1
  while [[ $USER_GUESS != $RANDOM_NUMBER ]]
  do
    read USER_GUESS
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      if [[ $USER_GUESS > $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $USER_GUESS < $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      elif [[ $USER_GUESS == $RANDOM_NUMBER ]]
      then
          ADD_USERNAME_RESULT=$($PSQL "insert into users(user_name) values('$USER_NAME')")
          NEW_USER_ID=$($PSQL "select user_id from users where user_name = '$USER_NAME'")
          SAVE=$($PSQL "insert into games(user_id,guesses) values($NEW_USER_ID,$NUMBER_OF_GUESSES)")
        echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!
      fi
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
    fi
  done


else
  echo $CHECK_USERNAME_RESULT | while IFS="|" read USER_ID USERNAME GAMES_NUMBER MIN_GUESS
  do
  echo "Welcome back, $USERNAME! You have played $GAMES_NUMBER games, and your best game took $MIN_GUESS guesses."
  done
  USER_ID=$($PSQL "select user_id from users where user_name = '$USER_NAME'")
  GAME $USER_ID
fi
