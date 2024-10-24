#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# MAIN_MENU(){
#    if [[ $1 ]]
#     then
#     echo -e "\n$1"
#   fi 
#   echo How may I help you?
#   echo -e "\n1. Select a service.\n2. Exit"
#   read MAIN_MENU_SELECTION
#   case $MAIN_MENU_SELECTION in
#     1) SELECT_SERVICE ;;
#     2) EXIT ;;
#     *) MAIN_MENU "Please enter a valid option." ;;
#   esac
# }

LIST_SERVICES(){
  if [[ $1 ]]
    then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVTCE_ID BAR NAME
  do
    echo "$SERVTCE_ID) $NAME"
  done
  echo -e "\nWhich service you do want?"
  read SERVICE_ID_SELECTED
}
LIST_SERVICES

if [[ ! $SERVICE_ID_SELECTED  =~ ^[0-9]+$ ]]
then
  #send to main menu
  LIST_SERVICES "That is not a valid bike number."
else
  SERVICE_AVAILABILITY=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_AVAILABILITY ]]
    then
    #send to main menu
    LIST_SERVICES "We don't have this service."
  else
    #get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #GET service time
    echo -e "\nWhat time will you like to have the appointment?"
    read SERVICE_TIME
    #set appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    SERVICE_INFO_FORMATTED=$(echo $SERVICE_INFO | sed 's/ |/"/')
    echo -e "\nI have put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
  fi
fi