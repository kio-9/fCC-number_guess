#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

RANDOM_NUMBER=$(( $RANDOM%1000 + 1 ))

echo $RANDOM_NUMBER

echo "Enter your username:"
read USERNAME

SELECTED_USER_INFO=$($PSQL "SELECT games_played,best_game FROM users WHERE username='$USERNAME'")
if [[ -z $SELECTED_USER_INFO ]]
then
echo "Welcome, $USERNAME! It looks like this is your first time here."
INSERT_RESULT=$($PSQL "INSERT INTO users(username,games_played) VALUES ('$USERNAME',1)")
else
echo $SELECTED_USER_INFO | while read GAMES_PLAYED BAR BEST_GAME
do
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
done
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

NUMBER_GUESSES=0
while [[ $GUESS != $RANDOM_NUMBER ]]
do
  # Check if integer
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    # Comparisons
    NUMBER_GUESSES=$(( $NUMBER_GUESSES + 1 ))
    if [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
    echo "It's lower than that, guess again:"
    fi
    if [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
    echo "It's higher than that, guess again:"
    fi
  else
  echo "That is not an integer, guess again:"
  fi
  read GUESS
done

NUMBER_GUESSES=$(( $NUMBER_GUESSES + 1 ))
echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
if [ -z $BEST_GAME ] || [ $BEST_GAME -gt $NUMBER_GUESSES ];
then
INSERT_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_GUESSES WHERE username='$USERNAME'")
fi
