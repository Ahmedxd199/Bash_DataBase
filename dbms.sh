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
function Open_DB
{
    ReadDBNameFromUSer
    if test -d $DBname
    then
        cd $DBname
        echo "done"
        MainTables
    else
        zenity --error --title="Error!" --text="$DBname doesn't exist!" --no-wrap
    fi

}
function list_DBs
{
   if [ "$(ls -d */)" ]
   then
    ls > .listOfDBs
    whiptail --title "Available Databases" --fb --scrolltext --textbox .listOfDBs 12 80
   else

   zenity --error --title="Error!" --text="No Databases to show!" --no-wrap
   fi
}
function Drop_DB
{
    ReadDBNameFromUSer
    if [ -d $DBname ]
    then
        input=$(whiptail --title "Are you sure you want to delete this Database?" --fb --menu "Confirm" 15 50 6 \
            "1" "yes" \
            "2" "no"  3>&1 1>&2 2>&3)
            case $input in
                    1 )  rm -r $DBname
                         zenity --info --title="Success" --text="$DBname has been removed successfully" --no-wrap
                    ;;
                    2 )
                        clear
                    ;;
            esac
    else
        zenity --error --title="Error!" --text="$DBname doesn't exist!" --no-wrap
    fi

}



function Open_Certain_table
{
    ReadTableNameFromUSer
    if [ -f $Tablename ]
    then
        #cat $Tablename
        Record_stage $Tablename
    else
        zenity --error --title="Error!" --text="$Tablename doesn't exist!" --no-wrap
    fi

}


function Record_stage
{
    Tablename=$1
    while input=$(whiptail --title "Records Menu" --menu "Choose an option" 15 50 6 \
     "1" "Show table" \
    "2" "Insert New Record"  \
    "3" "Delete Record"  \
    "4" "Update Certain Cell"  \
    "5" "Back to Tables Menu"   \
    "6" "Exit" 3>&1 1>&2 2>&3 )
    do  #read input
    case $input in
            1 ) DescribeTable $Tablename
            ;;
            2 ) InsertInto $Tablename
            ;;
            3 ) delete_record $Tablename
            ;;
            4 ) Update_cell $Tablename
            ;; 
            5 ) clear; MainTables  
            ;;
            6 ) clear; exit 0
            ;;
    esac
    done
    
}



function InsertInto
{
      Tablename=$1
    #   echo $Tablename > students;
      row=""
      if ! [ -f $Tablename ]
      then 
           zenity --error --title="Error!" --text="Table $Tablename doesn't exist!" --no-wrap
      else
      #Get num of rows stored in metadata file which represents the num of columns
      noOfCol=`(awk -F: 'END{print NR}' .$Tablename)`
      idx=2
      fs="|"
      colName=""
      colType=""
      colConstraint=""
      until [ $idx -gt $noOfCol ]
      do
         colName=`(awk -F'|' '{if(NR=='$idx') print $1}' .$Tablename)`
         colType=`(awk -F'|' '{if(NR=='$idx') print $2 }' .$Tablename)` 
         colConstraint=`(awk -F'|' '{if(NR=='$idx') print $3}' .$Tablename)`
         data=$(whiptail --inputbox "Enter data of column $colName" 8 39 3>&1 1>&2 2>&3)
         #Validate data type 
         if [[ "$colType" == "str" ]]   
         then
           while [[ true ]]
            do
                if [[ -z "$data" ]]
                then
                      zenity --error --title="Error!" --text="Empty string! \n " --no-wrap
                      data=$(whiptail --inputbox "Enter valid data (string)" 8 39 3>&1 1>&2 2>&3)
                else 
                    case $data in
                        +([a-zA-Z]) )
                            break
                            ;;
                        *)
                            zenity --error --title="Error!" --text="Invalid data type! \n " --no-wrap
                            data=$(whiptail --inputbox "Enter valid data type (string)" 8 39 3>&1 1>&2 2>&3)
                            ;;
                        esac
                fi
            done
         elif [[ "$colType" == "int" ]]
         then
           while [[ true ]]
            do
                case $data in 
                    +([0-9]) )
                            # Check if the entered PK already exists
                                if [[ "$colConstraint" == "PK" ]]
                                then
                                    flag2=1
                                    let exist=0
                                    while [[ true ]]
                                    do
                                        if [[ -z "$data" ]]
                                        then 
                                                zenity --error --title="Error!" --text="PK can't be NULL ! \n " --no-wrap
                                                data=$(whiptail --inputbox "Enter valid Primary key" 8 39 3>&1 1>&2 2>&3)

                                        elif ! [[ $data =~ ^[1-9][0-9]*$ ]]
                                        then
                                                zenity --error --title="Error!" --text="Invalid data type! \n " --no-wrap
                                                data=$(whiptail --inputbox "Enter valid data type (int)" 8 39 3>&1 1>&2 2>&3)
                                        else
                                            exist=`(awk -F'|' '{if('$data'==$('$idx'-1)) print $('$idx'-1)}' $Tablename)` 
                                            if ! [[ $exist -eq 0  ]]
                                            then
                                                zenity --error --title="Error!" --text="PK already exists! \n " --no-wrap
                                                data=$(whiptail --inputbox "Enter unique Primary key" 8 39 3>&1 1>&2 2>&3)
                                                set exist=0
                                            else
                                                break
                                            fi
                                        fi
                                    done
                                fi
                                break
                        ;;
                    *) zenity --error --title="Error!" --text="Invalid data type! \n " --no-wrap
                        data=$(whiptail --inputbox "Enter valid data type (int)" 8 39 3>&1 1>&2 2>&3)
                        ;;
                    esac
            done
        fi
         
        # Set row data
        if ! [ $idx -eq $noOfCol ]
        then
            row=$row$data$fs  
        else
            row=$row$data
        fi
        ((idx++))
      done
     
      echo $row >> $Tablename
      if [ $? -eq 0 ]
        then 
            zenity --info --title="Success" --text="Data inserted successfully \n " --no-wrap
            #echo "Data inserted successfully"
        else
            zenity --error --title="Error" --text="Filed to insert data \n " --no-wrap
            #echo "Error !"
        fi
      fi
}



function delete_record
{
   Tablename=$1
   let idx=2
   #pk=$(zenity --entry --title="Enter PK of the record you want to delete")
   pk=$(whiptail --inputbox "Enter PK of the record you want to delete" 8 39 3>&1 1>&2 2>&3)   # for ex) pk = 3
   noOfCol=$(awk -F: 'END{print NR}' .$Tablename)    
   until [ $idx -gt $noOfCol ]
    do
         colConstraint=$(awk -F'|' '{if(NR=='$idx') print $3}' .$Tablename)      # colConstraint = pk or ""
         if [[ "$colConstraint" == "PK" ]]     
        then
            # GET the Record number using the PK 
            #check the entered Pk with all values by feild number 'idx'-1
            recordnumber=$(awk -F'|' '{if($('$idx'-1)=='$pk') print NR}' $Tablename) #recordnumber = 3
         #   echo $recordnumber >> test
            # Check if the entered PK exist? "Delete" : "not found!" 
            if [[ "$recordnumber" =~ ^[0-9]+$ ]]
            then
                 input=$(whiptail --title "Are you sure you want to delete this record?" --fb --menu "Confirm deletion" 15 50 6 \
                "1" "yes" \
                "2" "no"  3>&1 1>&2 2>&3)
                case $input in
                        1 ) 
                            # Delete the record using the record number, then redirect to a new file and rename its name with table name :)
                            awk -v n=$recordnumber 'NR == n {next} {print}' $Tablename > tmp && mv tmp $Tablename
                        ;;
                        2 ) 
                            zenity --warning --title="Warning" --text="Terminating without deleting" --no-wrap
                            break
                        ;;
                esac
            else
                zenity --error --title="Error!" --text="$pk doesn't exist!" --no-wrap
                break
            fi
            if [ $? -eq 0 ]
            then 
                zenity --info --title="Success" --text="Record has been deleted successfully" --no-wrap
            else
                 zenity --error --title="Error!" --text="Error deleting the record!" --no-wrap
            fi
            break
        fi

    ((idx++))
    done
}


function Drop_table
{
    ReadTableNameFromUSer
    if [ -f $Tablename ]
    then 
        input=$(whiptail --title "Are you sure you want to delete this table?" --fb --menu "Confirm" 15 50 6 \
            "1" "yes" \
            "2" "no"  3>&1 1>&2 2>&3)
            case $input in
                    1 )  rm $Tablename .$Tablename
                         zenity --info --title="Success" --text="$Tablename Table has been removed successfully :)" --no-wrap
                    ;;
                    2 ) 
                        clear
                    ;;
            esac
    else
        zenity --error --title="Error!" --text="$Tablename Table doesn't exist!" --no-wrap
    fi  

}



MainDB
