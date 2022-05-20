"""
Program Name: Console_App.py
Description: A console application that connects to a mariadb database and allows the user to upload, edit, and delete table entries.
Author: Madeline Gerbitz
Last Modified: 5/10/22 8pm CST
Total Time Worked on: 10hrs
"""

import mariadb
import sys
import re
import os

#Setup a screen clearing function to clear the console.
clear = lambda: os.system('clear')

#Attempt to initialize a connection with the database/
try:
    conn = mariadb.connect(
        user="########", 
        password="########", 
        host="########", 
        port=########, 
        database="########")

#If the attempt to connect fails print an error and exit program.
except mariadb.Error as e:
    print(f"Error connecting to maria: {e}")
    sys.exit(1)

#Cursor object
cur = conn.cursor()

#Actions list so I don't have to type a ton of messages.
actions = ["Upload", "Edit", "Delete"]

"""
The main loop of this program.
The cursor object is passed into this function and through to most other functions to ensure its usage is available everywhere.
This loop will present a menu to the user in the console and allow them to input their selection.
If the user fails to input a valid option the screen will clear, reset, and ask again after providing a short error message.
"""
def MainLoop(cur):
    print("Welcome to the Konsole based Internal Table editor (KIT) for short.")
    print("Remember to exit from the main menu to save your changes!")
    print("Options: ")
    print("1- Upload Entry to Table     2- Edit Entry in Table      3- Delete Entry from Table      4- Exit KIT system")
    MainMenuOption = re.search("^(1|2|3|4)$",str(input())) #This regex, the first attribute of the search function, makes sure the user only selects 1 through 4.
    if(MainMenuOption):
        if(MainMenuOption.string == "4"):
            clear()
            print("Thank you for using the KIT system!\nShutting Down...")
            input("press the any key to exit program")
            conn.commit()
            conn.close()
            sys.exit(0)
        else:
            clear()
            SelectTable(cur, MainMenuOption.string) #Once a valid option is selected the program will move on to the table selection function.
            
    else:
        clear()
        print("Please select an a valid option. (1-4)\n")
        MainLoop(cur)

"""
The table selection function.
This function displays a message with the action the user chose in the first menu.
Then it executes a show tables command on the active database to dynamically list all available tables.
The regex here took me like 30 minutes to figure out, but I'm confident that it will prevent invalid options from getting through.
"""
def SelectTable(cur, Action):
    print("You have chosen to " + actions[int(Action)-1] + " an entry. Please select which table you would like to do this in.")
    print("Available tables:")
    cur.execute("SHOW TABLES")
    TableCount = 1
    TableSearch = r"^("
    TableList = []
    for table in cur:
        TableSearch += str(TableCount) + "|"
        TableList.append(re.sub(r"[',()]", "", str(table)))
        print(str(TableCount) + ": " + TableList[TableCount-1])
        TableCount += 1
    
    TableSearch = TableSearch[:-1] + ")$"

    SelectTableOption = re.search(TableSearch,str(input()))
    #This if block will take the action selected in the first menu and move into the corresponding function while passing along the selected table.
    if(SelectTableOption):
        clear()
        if Action == "1":
            UploadEntry(cur, Action, TableList[int(SelectTableOption.string)-1])
        if Action == "2":
            EditEntry(cur, Action, TableList[int(SelectTableOption.string)-1])
        if Action == "3":
            DeleteEntry(cur, Action, TableList[int(SelectTableOption.string)-1])
    else:
        clear()
        print("Please select a valid option.")
        SelectTable(cur, Action)

"""
UploadEntry:
Grabs 3 lists from the EntryInfoInput function and then builds a SQL insert command using them.
This command is built dynamically.
"""
def UploadEntry(cur, Action, TableName):
    FieldTypes, FieldNames, EntryInfo = EntryInfoInput(cur, Action, TableName)
    try:
        command = f"INSERT INTO {TableName} ("
        nameCount = 0
        for name in FieldNames:
            command += f"{FieldNames[nameCount]}, "
            nameCount += 1
        command = command[:-2] + ") VALUES ("
        valueCount = 0
        for value in EntryInfo:
            command += f"'{EntryInfo[valueCount]}', "
            valueCount += 1
        command = command[:-2] + ")"
        cur.execute(command)
    except mariadb.Error as e:
        print("Please try entering your information again...")
        print(e)
        UploadEntry(cur, Action, TableName)
    ReturnToMain(cur, Action, TableName)

"""
EditEntry:
Grabs the entryID from the EntrySelect function.
Grabs 3 lists from the EntryInfoInput function.
Then builds a SQL adjust command using them.
This command is built dynamically.
"""
def EditEntry(cur, Action, TableName):
    EntryID = EntrySelect(cur, Action, TableName)
    FieldTypes, FieldNames, EntryInfo = EntryInfoInput(cur, Action, TableName)
    try:
        cur.execute(f"SHOW COLUMNS FROM {TableName} WHERE Extra LIKE 'auto_increment'")
        PrimaryKey = ""
        for key in cur:
            PrimaryKey = re.sub(r"[',()]", "", str(key[0]))
        command = f"UPDATE {TableName} SET "
        commandCount = 0
        for Entry in EntryInfo:
            command += f"{FieldNames[commandCount]}='{EntryInfo[commandCount]}', "
            commandCount +=1
        command = command[:-2] + f" WHERE {PrimaryKey}={EntryID}"
        cur.execute(command)
    except mariadb.Error as e:
        print("Please try entering your information again...")
        print(e)
        EditEntry(cur, Action, TableName)
    ReturnToMain(cur, Action, TableName)

"""
DeleteEntry:
Grabs the entryID from the EntrySelect function.
Then builds a SQL delete command using them.
This command is built dynamically.
"""
def DeleteEntry(cur, Action, TableName):
    EntryID = EntrySelect(cur, Action, TableName)
    try:
        cur.execute(f"SHOW COLUMNS FROM {TableName} WHERE Extra LIKE 'auto_increment'")
        PrimaryKey = ""
        for key in cur:
            PrimaryKey = re.sub(r"[',()]", "", str(key[0]))
        command = f"DELETE FROM {TableName} WHERE {PrimaryKey}={EntryID}"
        cur.execute(command)
    except mariadb.Error as e:
        print("Please try entering your information again...")
        print(e)
        DeleteEntry(cur, Action, TableName)
    ReturnToMain(cur, Action, TableName)

"""
EntrySelect:
Sends a SQL command to the database to retrieve the number of entries in the current table.
Tells the user how many entries are in the table then asks them to select one.
"""
def EntrySelect(cur, Action, TableName):
    cur.execute(f"SELECT COUNT(*) FROM {TableName}")
    for count in cur:
        print(f"""Number of records in {TableName}: {re.sub(r"[',()]", "", str(count))}""")
    EntryCount = int(re.sub(r"[',()]", "", str(count)))
    EntrySearch = r"^("
    for EntryNum in range(EntryCount):
        EntrySearch += str(EntryNum+1) + "|"
    EntrySearch = EntrySearch[:-1] + ")$"

    SelectEntryID = re.search(EntrySearch,str(input("Choose an ID: ")))
    if(SelectEntryID):
        return int(SelectEntryID.string)-1
    else:
        clear()
        print("Please select a valid option.")
        EntrySelect(cur, Action, TableName)

"""
EntryInfoInput:
Sends a SQL command to the database to retrieve a list of not auto incremented columns from the current table.
Then it iterates through these columns listing their names and types, while asking the user for input on each column.
This command is very dynamic.
"""
def EntryInfoInput(cur, Action, TableName):
    cur.execute(f"SHOW COLUMNS FROM {TableName} WHERE Extra NOT LIKE 'auto_increment'")
    FieldCount = 0
    EntryInfo = []
    FieldNames = []
    FieldTypes = []
    for field in cur:
        FieldNames.append(re.sub(r"[',()]", "", str(field[0])))
        print("Field Name: " + FieldNames[FieldCount])
        FieldTypes.append(re.sub(r"[',()]", "", str(field[1])))
        print("Field Type: " + FieldTypes[FieldCount])
        if field[1] == "datetime":
            print("yyyy-mm-dd hh:mm:ss")
        EntryInfo.append(input("\n Enter info here: "))
        FieldCount += 1
        clear()

    return FieldTypes, FieldNames, EntryInfo

"""
ReturnToMain:
Asks the user if they would like to return to the main menu. If they wish to continue it'll move them to the ChangeTablesPrompt.
"""
def ReturnToMain(cur, Action, TableName):
    print("Would you like to return to the main menu?")
    print(f"1: Yes, return to main menu\n2: No, continue {actions[int(Action)-1]}ing.")
    ReturnMenuOption =  re.search("^(1|2)$",str(input()))
    print(ReturnMenuOption)
    if(ReturnMenuOption):
        clear()
        if ReturnMenuOption.string == "1":
            MainLoop(cur)
        if ReturnMenuOption.string == "2":
            ChangeTablesPrompt(cur, Action, TableName)
    else:
        clear()
        print("Please select a valid option.")
        ReturnToMain(cur, Action, TableName)

"""
ChangeTablesPrompt:
Asks the user if they would like to change the table they're currently interacting with.
"""
def ChangeTablesPrompt(cur, Action, TableName):
    print("Would you like to change the table you're working on?")
    print(f"Current table: {TableName}")
    print(f"1: Change Table\n2: Continue using {TableName}")
    ChangeMenuOption = re.search("^(1|2)$", str(input()))
    if(ChangeMenuOption):
        clear()
        if(ChangeMenuOption.string == "1"):
            SelectTable(cur, Action)
        if(ChangeMenuOption.string == "2"):
            if Action == "1":
                UploadEntry(cur, Action, TableName)
            if Action == "2":
                EditEntry(cur, Action, TableName)
            if Action == "3":
                DeleteEntry(cur, Action, TableName)
    else:
        clear()
        print("Please select a valid option.")
        ChangeTablesPrompt(cur, Action, TableName)

clear()
MainLoop(cur)
