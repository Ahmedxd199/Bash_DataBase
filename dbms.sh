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




function Create_table
{
    ReadTableNameFromUSer
    seperator="|"
    raw_seperator="\n"
    pkey=""
    declare columnsNumber
    declare -A metaData_data
    if [ -f $Tablename ]
    then
        zenity --error --title="Error!" --text="$Tablename already exist!" --no-wrap
    else
        
        while ! [[ $columnsNumber =~ ^[0-9]+$ ]]
        do
           columnsNumber=$(whiptail --inputbox "Enter Number of Columns" 8 39 3>&1 1>&2 2>&3)
        done

        metaData_def="Column Name"$seperator"Type"$seperator"Primary Key"
        
        showNumber=1
        for (( counter = 0; counter < $columnsNumber; counter++ ));
        do
            _counter=0
            #echo -e "Name of Column Number "$showNumber": \c"
            #read columnName
            columnName=$(whiptail --inputbox "Enter Name of Column Number $showNumber" 8 39 3>&1 1>&2 2>&3)
            ((showNumber++))
            data[$counter]=$columnName
            metaData_data[$counter,$_counter]=$columnName # metaData_data[0,0] = id
            ((_counter++))

            input=$(whiptail --title "Type of Column $columnName" --fb --menu "Choose data type" 15 50 6 \
            "1" "integer" \
            "2" "string"  3>&1 1>&2 2>&3)
            case $input in
                    1 ) 
                        columnType="int"
                    ;;
                    2 ) 
                        columnType="str"
                    ;;
            esac

            metaData_data[$counter,$_counter]=$columnType # metaData_data[0,1] = type(int or str)
            ((_counter++))
             #zenity --error --title="Error!" --text="$pKey here!" --no-wrap
            if [[ $pKey == "" ]]; 
            then
                input=$(whiptail --title "Would you like to set as Primary Key ?" --fb --menu "Set a PK" 15 50 6 \
                "1" "yes" \
                "2" "no"  3>&1 1>&2 2>&3)
                case $input in
                     1 ) pKey="PK"; metaData_data[$counter,$_counter]="$pKey";
                        ;;
                     2 ) metaData_data[$counter,$_counter]="";
                        ;;
                esac
            else
                metaData_data[$counter,$_counter]="";
            fi

        done
        
        if [[ $pKey != "" ]]
        then 
                # Print MetaData
                touch .$Tablename
                echo -e $metaData_def >> .$Tablename
                for (( counter = 0; counter < $columnsNumber; counter++ ));
                do  
                    for (( _counter = 0; _counter < 3; _counter++ ));
                    do
                        if [ $_counter == 2 ]
                        then
                            echo -n -e "${metaData_data[$counter,$_counter]}" >> .$Tablename
                        else
                            echo -n -e "${metaData_data[$counter,$_counter]}""$seperator" >> .$Tablename  
                        fi 
                    done  
                    echo -n -e "$raw_seperator" >> .$Tablename  
                done

                # Print Actual Data
                touch $Tablename
                ((flag=$columnsNumber-1))
                for (( counter = 0; counter < $columnsNumber; counter++ )); 
                do
                    if [[ $counter == $flag ]]
                    then
                        echo -n "${data[$counter]}"  >> $Tablename
                        echo -n -e "$raw_seperator" >> $Tablename
                    else
                        echo -n "${data[$counter]}""$seperator" >> $Tablename
                    fi
                done
        fi
        # Check The Process
        if [[ $? == 0 && $pKey != "" ]]
        then
            zenity --info --title="Completed!" --text="Table Created Successfully :)" --no-wrap
        else
            zenity --error --title="Error" --text="NOT Successful Creation of Table $Tablename ! \n You must set a column as a primary key" --no-wrap
        fi
    fi   
    unset pKey   
}




]

function MainDB
{  
    while input=$(whiptail --title "Database Menu" --menu "Choose an option" 15 50 6 \
    "1" "Create Database" \
    "2" "Open Database" \
    "3" "Drop Database"  \
    "4" "List Database"   \
    "5" "Exit" 3>&1 1>&2 2>&3 )
    do
    case $input in
            1 ) 
                Create_DB
            ;;
            2 ) 
                Open_DB 
            ;;
            3 ) 
                Drop_DB
            ;;
            4 ) 
                list_DBs 
            ;;
            5 ) 
                clear; exit 0
            ;;
    esac
    done
}

function ReadDBNameFromUSer
{
    DBname=$(whiptail --inputbox "Enter Database name" 8 39  --title "Database" 3>&1 1>&2 2>&3)
}

function Create_DB
{ 
    ReadDBNameFromUSer
    if test -d $DBname
    then
        zenity --warning --title="Already exists!" --text="$DBname already exists!" --no-wrap
    else
        mkdir $DBname
        zenity --info --title="success" --text="Database $DBname has been created successfully :)" --no-wrap
    fi

}

MainDB
