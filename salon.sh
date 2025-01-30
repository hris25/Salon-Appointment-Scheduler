#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

function MAIN_MENU {
  if [[ -z $1 ]]
  then 
    echo -e "Welcome to My Salon, how can I help you?\n"
  else 
    echo -e "\n$1"
  fi
  
  SERVICE_LIST=$($PSQL "SELECT service_id,name FROM services" --tuples-only)
  echo "$SERVICE_LIST" | while read SERVICE_ID NAME 
  do
    echo "$SERVICE_ID) $NAME " | sed 's/ |//'
  done
  read SERVICE_ID_SELECTED
  HANDLE $SERVICE_ID_SELECTED
}

function HANDLE {
  SERVICE_EXIST=$($PSQL "SELECT * FROM services WHERE service_id=$1" --tuples-only)
  if [[ -z $SERVICE_EXIST  ]] 
  then 
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    GET_CUSTOMER=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'" --tuples-only)
    if [[ -z $GET_CUSTOMER ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME
      GET_CURRENT_CUSTOMER=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" --tuples-only) 

      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($GET_CURRENT_CUSTOMER, '$SERVICE_TIME', $1)")

      echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      GET_CURRENT_CUSTOMER=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'" --tuples-only)

      echo $GET_CURRENT_CUSTOMER | while IFS='|' read ID PHONE NAME
      do
        CUSTOMER_PHONE=$PHONE
        CUSTOMER_ID=$ID
        CUSTOMER_NAME=$NAME 
        echo -e "\nWhat time would you like your color,$NAME?"
        read SERVICE_TIME

        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $1)")
        echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
      done

    fi


  fi
}






MAIN_MENU
