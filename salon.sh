#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
 if [[ -n $1 ]]
 then
 echo -e "\n$1"
 else 
 echo -e "Welcome to My Salon, how can I help you?\n"
 fi
 #Store options in SALON_OPTIONS
 SALON_OPTIONS=$($PSQL "SELECT service_id, name FROM services")
 echo "$SALON_OPTIONS" | while read SERVICE_ID BAR NAME
 do
  #Print options
  echo "$SERVICE_ID) $NAME"
 done
 
 #Read option from user
 read SERVICE_ID_SELECTED
 
 SERVICE_ID_SELECTED_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

 if [[ -z $SERVICE_ID_SELECTED_EXISTS ]]
 then
  MAIN_MENU "I could not find that service. What would you like today?"
 else
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_PHONE_EXISTS=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_PHONE_EXISTS ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  if [[ -z $CUSTOMER_NAME ]]
  then
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  #grab customer option name by service_id
  CUSTOMER_OPTION=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED_EXISTS'")
  #grab customer id by phone
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your $(echo $CUSTOMER_OPTION | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  #Read time of service
  read SERVICE_TIME

  #Insert appointment in the database
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED_EXISTS')")

  echo -e "\nI have put you down for a $(echo $CUSTOMER_OPTION | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
 fi
}

MAIN_MENU