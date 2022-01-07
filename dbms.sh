#!/bin/bash



function MainTables
{
    while input=$(whiptail --title "Tables Menu" --menu "Choose an option" 15 50 6 \
    "1" "List All Tables"  \
    "2" "Open Certain Table"  \
    "3" "Create Table"   \
    "4" "Drop Table"    \
    "5" "Back to DB Menu"  \
    "6" "Exit" 3>&1 1>&2 2>&3)
    do
    case $input in
            1 ) List_All_Tables
            ;;
            2 ) Open_Certain_table
            ;;
            3 ) Create_table
            ;;
            4 ) Drop_table
            ;;
            5 ) clear; cd ../; MainDB
            ;;
            6 ) clear; exit 0
            ;;
    esac
    done
}


function ReadTableNameFromUSer
{
    Tablename=$(whiptail --inputbox "Enter Table name" 8 39 3>&1 1>&2 2>&3)
}

]