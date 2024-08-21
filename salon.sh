#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Drew's Salon ~~~~~\n"

MAIN_MENU() {
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo -e "Welcome to Drew's Salon! How can we help you?\n"

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_VALID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  if [[ ! -n $SERVICE_VALID ]]
  then
    echo -e "\nSelection is invalid, please try again."
    MAIN_MENU
  else
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_EXISTS=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ ! -n $CUSTOMER_EXISTS ]]
    then
      echo -e "\nHmmm... I don't see you in the system. Let me add you...\n\nWhat's your name?"
      read CUSTOMER_NAME
      ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    echo -e "\nGreat! I've got you in the system, $CUSTOMER_NAME...\n\nWhat time would you like to book for?"
    read SERVICE_TIME

    CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\n"
    echo "I have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME,$CUSTOMER_NAME."
  fi
}

MAIN_MENU