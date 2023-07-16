#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"

Menu(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  Services=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $Services ]]
  then
    echo "Sorry, there are no available services right now"
  else
    echo "$Services" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done 

    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      Menu "That's not a number"
    else
      SERVICE_AVAIL=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_AVAIL ]]
      then
        Menu "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone= '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        fi
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone= '$CUSTOMER_PHONE'")
        if [[ $SERVICE_TIME ]]
        then
          INSERT_INTO_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          if [[ $INSERT_INTO_RESULT ]]
          then
            echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g'). "
          fi
        fi
      fi
    fi  
  fi
}

Menu
