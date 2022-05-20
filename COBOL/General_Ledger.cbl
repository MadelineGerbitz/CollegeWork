       IDENTIFICATION DIVISION.
       PROGRAM-ID. General_Ledger.
       AUTHOR. Jack Madeline Nate.
       DATE-WRITTEN. 3/7/22.
      ******************************************************************
      *This project will receive data from a transaction file.
      *It will then determine a record's activity, assign it an
      *entry number, commit it to the master journal file, and commit
      *changes to the chart of accounts file.
      ******************************************************************

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *Master file contains journal postings 
           SELECT MASTER-FILE
               ASSIGN TO UT-SYS-MASTER-FILE
               ORGANIZATION IS SEQUENTIAL.
      *Trans file contains transactions from other departments.
           SELECT TRANS-FILE
               ASSIGN TO UT-SYS-TRANS-FILE
               ORGANIZATION IS SEQUENTIAL.
      *Chart file contains account IDs, Titles, and balances.      
           SELECT CHART-FILE
               ASSIGN TO UT-SYS-CHART-FILE
               ORGANIZATION IS SEQUENTIAL.
      *Control file contains last journal number.
           SELECT CONTROL-FILE
               ASSIGN TO UT-SYS-CONTROL-FILE
               ORGANIZATION IS SEQUENTIAL.
            

       DATA DIVISION.
       FILE SECTION.
       FD MASTER-FILE
           RECORD CONTAINS 38.
       01 MASTER-INFO.
           05 MST-JOURNAL-NUMBER PIC 9(8).
           05 MST-DEPARTMENT-CODE PIC 9.
            88 DEPT-TIC VALUE 1.
            88 DEPT-CON VALUE 2.
            88 DEPT-POC VALUE 3.
           05 MST-TRANS-AMT PIC S9(8)V99 SIGN IS LEADING 
           SEPARATE CHARACTER.
           05 MST-TRANS-TYPE PIC X(1).
            88 TYPE-DEBIT VALUE 'D'.
            88 TYPE-CREDIT VALUE 'C'.
           05 MST-ACC-ID PIC 9.
            88 ACC-CASH VALUE 1.
            88 ACC-SALES VALUE 2.
            88 ACC-EXPENSES VALUE 3.
           05 MST-DATE-TRANS PIC 9(8).
           05 MST-DATE-ENTERED PIC 9(8).
           
       FD TRANS-FILE
           RECORD CONTAINS 21.
       01 TRANS-INFO.
           05 TRANS-DEPT-CODE PIC 9.
            88 DEPT-TIC VALUE 1.
            88 DEPT-CON VALUE 2.
            88 DEPT-POC VALUE 3.
           05 TRANS-AMT PIC S9(8)V99 SIGN IS LEADING SEPARATE CHARACTER.
           05 TRANS-ACC PIC 9.
            88 ACC-CASH VALUE 1.
            88 ACC-SALES VALUE 2.
            88 ACC-EXPENSES VALUE 3.
           05 TRANS-DATE PIC 9(8).

       FD CHART-FILE
           RECORD CONTAINS 28.
       01 CHART-INFO.
           05 CH-ACC-ID PIC 9.
           05 CH-ACC-NAME PIC X(16).
           05 CH-ACC-BALANCE PIC S9(8)V99 SIGN IS LEADING 
           SEPARATE CHARACTER.

       FD CONTROL-FILE
           RECORD CONTAINS 8.
       01 CONTROL-INFO.
           05 LAST-JOURNAL-NUMBER PIC 9(8). 

       WORKING-STORAGE SECTION.
      ******************************************************************
      *Set value to "C:\COBOL\{file} for Windows environments.
      *Set value to "./data/{file} for Linux environments.
      ****************************************************************** 
       01 WS-FILENAMES.
           05 UT-SYS-MASTER-FILE PIC x(100) 
              VALUE "C:\COBOL\master.dat".
           05 UT-SYS-TRANS-FILE PIC x(100) 
              VALUE "C:\COBOL\trans.dat".
           05 UT-SYS-CHART-FILE PIC X(100) 
              VALUE "C:\COBOL\chart.dat".
           05 UT-SYS-CONTROL-FILE PIC X(100) 
              VALUE "C:\COBOL\control.dat".

      ******************************************************************
      *EOF switches are used to read through a file without going past
      *the end of file.
      ******************************************************************
       01 WS-PROGRAM-SWITCHES.
           05 WS-EOF-TRANS-SWITCH PIC X(1).
            88 EOF-TRANS VALUE "T".
            88 NOT-EOF-TRANS VALUE "F".
           05 WS-EOF-CONTROL-SWITCH PIC X(1).
            88 EOF-CONTROL VALUE "T".
            88 NOT-EOF-CONTROL VALUE "F".
           05 WS-EOF-CHART-SWITCH PIC X(1).
            88 EOF-CHART VALUE "T".
            88 NOT-EOF-CHART VALUE "F".

      ******************************************************************
      *Temp variables are used for keeping track of info used for
      *multiple records.
      ******************************************************************
       01 WS-TEMP-VARIABLES.
           05 CURRENT-JOURNAL-NUMBER PIC 9(8).
           05 WS-SALES-TOTAL PIC S9(8)V99.
           05 WS-EXPENSE-TOTAL PIC S9(8)V99.

      ******************************************************************
      *Current date stores the date a record is processed.
      ******************************************************************
       01 WS-CURRENT-DATE-DATA.
           05 WS-CURRENT-DATE.
            10 WS-CURRENT-YEAR PIC 9(4).
            10 WS-CURRENT-MONTH PIC 9(2).
            10 WS-CURRENT-DAY PIC 9(2).
        
       PROCEDURE DIVISION.
      ******************************************************************
      *Main loop.
      *Step 1: Perform prep
      *Step 2: Enter main read loop
      *Step 3: Perform commits to chart and control
      *Step 4: Close any open files and stop the program
      ****************************************************************** 
       100-MAIN.
            OPEN INPUT TRANS-FILE
                EXTEND MASTER-FILE
                   I-O CONTROL-FILE
      *Prep
           PERFORM 200-PREP-CONTROL
      *Read trans/process loop
           MOVE "F" TO WS-EOF-TRANS-SWITCH
           PERFORM 210-READ THRU 210-READ-EXIT
               UNTIL WS-EOF-TRANS-SWITCH = "T"
      *Commit to IO files
           OPEN I-O CHART-FILE
           MOVE "F" TO WS-EOF-CHART-SWITCH
           PERFORM 810-COMMIT-CHART THRU 810-COMMIT-CHART-EXIT
                UNTIL WS-EOF-CHART-SWITCH = "T"
           CLOSE CHART-FILE
           PERFORM 700-WRITE-TO-CONTROL

           CLOSE MASTER-FILE
                 TRANS-FILE
                 CONTROL-FILE
           STOP RUN.
      ******************************************************************
      *Loads the last used journal number from the control file.
      ******************************************************************
       200-PREP-CONTROL.
           READ CONTROL-FILE
           MOVE LAST-JOURNAL-NUMBER TO CURRENT-JOURNAL-NUMBER.
       200-PREP-CONTROL-EXIT.
           EXIT.

      ******************************************************************
      *This reads the data from the input file and steps into the
      *processing function.
      ******************************************************************     
       210-READ.
           READ TRANS-FILE
                AT END
                   MOVE "T" TO WS-EOF-TRANS-SWITCH
                NOT AT END
                   PERFORM 220-PROCESS-RECORD
           END-READ.
       210-READ-EXIT.
           EXIT.

      ******************************************************************
      *Process the current transaction record.
      *Step 1: Move static transaction variables to the master record
      *Step 2: Step into determine account activity
      *Step 3: Step into assign journal number
      *Step 4: Commit the master transaction to the journal file.
      *Step 5: Update the chart.
      ******************************************************************
       220-PROCESS-RECORD.
           MOVE TRANS-AMT TO MST-TRANS-AMT
           MOVE TRANS-ACC TO MST-ACC-ID
           MOVE TRANS-DATE TO MST-DATE-TRANS
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-DATA
           MOVE WS-CURRENT-DATE-DATA TO MST-DATE-ENTERED
           PERFORM 300-DETERMINE-ACCOUNT-ACTIVITY
           PERFORM 400-ASSIGN-JOURNAL-NUMBER
           PERFORM 500-WRITE-TO-MASTER
           OPEN I-O CHART-FILE
           MOVE "F" TO WS-EOF-CHART-SWITCH
           PERFORM 800-UPDATE-CHART THRU 800-UPDATE-CHART-EXIT
                UNTIL WS-EOF-CHART-SWITCH = "T"
           CLOSE CHART-FILE
           DISPLAY "RECORD PROCESSED".
       220-PROCESS-RECORD-EXIT.
           EXIT.
      ******************************************************************  
      *Compare a transaction's dept. code, balance, and target account
      *to determine activity.
      ****************************************************************** 
       300-DETERMINE-ACCOUNT-ACTIVITY.
           MOVE TRANS-DEPT-CODE TO MST-DEPARTMENT-CODE
           IF TRANS-DEPT-CODE = 1
               IF TRANS-AMT < 0
                   MOVE 'D' TO MST-TRANS-TYPE
               ELSE
                   MOVE 'C' TO MST-TRANS-TYPE
               END-IF
           ELSE IF TRANS-DEPT-CODE = 2
               IF TRANS-AMT < 0
                   MOVE 'D' TO MST-TRANS-TYPE
               ELSE
                   MOVE 'C' TO MST-TRANS-TYPE
               END-IF
           ELSE IF TRANS-DEPT-CODE = 3
               IF TRANS-AMT < 0
                   MOVE 'C' TO MST-TRANS-TYPE
               ELSE
                   MOVE 'D' TO MST-TRANS-TYPE
               END-IF
           ELSE
               DISPLAY "DEPARTMENT CODE INVALID"
           END-IF.
       300-DETERMINE-ACCOUNT-ACTIVITY-EXIT.
           EXIT.

      ******************************************************************
      *Grabs the Journal Number from working storage, increments it,
      *then assigns it to the current journal entry.
      ******************************************************************
       400-ASSIGN-JOURNAL-NUMBER.
           MOVE CURRENT-JOURNAL-NUMBER TO MST-JOURNAL-NUMBER
           ADD 1 TO CURRENT-JOURNAL-NUMBER.
       400-ASSIGN-JOURNAL-NUMBER-EXIT.
           EXIT.
      ******************************************************************
      *Commits a completed transaction to the master journal file.
      ******************************************************************
       500-WRITE-TO-MASTER.
           WRITE MASTER-INFO BEFORE ADVANCING 1 LINE.
       500-WRITE-TO-MASTER-EXIT.
           EXIT.
    
      ******************************************************************
      *Commits a transaction to the chart of accounts.
      ******************************************************************
       700-WRITE-TO-CONTROL.
           MOVE CURRENT-JOURNAL-NUMBER TO LAST-JOURNAL-NUMBER
           REWRITE CONTROL-INFO.
       700-WRITE-TO-CONTROL-EXIT.
           EXIT.
      ******************************************************************
      *Updates chart of accounts balances
      *Does not let transactions write directly to cash.
      *Does not let TIC or CON write to expenses.
      *Does not let POC write to sales.
      *Checks how a department interacts with an account.
      ******************************************************************
       800-UPDATE-CHART.
           READ CHART-FILE
                AT END
                   MOVE "T" TO WS-EOF-CHART-SWITCH
                NOT AT END
                   IF MST-ACC-ID = CH-ACC-ID
                       IF CH-ACC-ID = 1
                          DISPLAY "Cannot write directly to cash acc."
                       ELSE IF CH-ACC-ID = 2
                          IF MST-DEPARTMENT-CODE = 3
                             DISPLAY "POC cannot write to sales."
                          ELSE IF MST-DEPARTMENT-CODE IS NOT = 3
                             IF MST-TRANS-TYPE = "C"
                                DISPLAY "ADD TO SALES"
                                ADD TRANS-AMT TO CH-ACC-BALANCE
                                ADD TRANS-AMT TO WS-SALES-TOTAL
                                REWRITE CHART-INFO
                             ELSE
                                DISPLAY "SUBTRACT FROM SALES"
                                ADD TRANS-AMT TO CH-ACC-BALANCE
                                ADD TRANS-AMT TO WS-SALES-TOTAL
                                REWRITE CHART-INFO
                             END-IF
                           END-IF
                       ELSE IF CH-ACC-ID = 3
                          IF MST-DEPARTMENT-CODE IS NOT = 3
                             DISPLAY 
                             "CON and TIC cannot write to expenses."
                          ELSE IF MST-DEPARTMENT-CODE = 3
                             IF MST-TRANS-TYPE = "C"
                                SUBTRACT TRANS-AMT FROM CH-ACC-BALANCE
                                SUBTRACT TRANS-AMT FROM WS-EXPENSE-TOTAL
                                REWRITE CHART-INFO
                             ELSE
                                SUBTRACT TRANS-AMT FROM CH-ACC-BALANCE
                                SUBTRACT TRANS-AMT FROM WS-EXPENSE-TOTAL
                                REWRITE CHART-INFO
                             END-IF
                          END-IF
                       END-IF
                   END-IF
           END-READ.
       800-UPDATE-CHART-EXIT.
           EXIT.

      ******************************************************************
      *Commits changes in sales acc and expense acc to the cash acc.
      ******************************************************************
       810-COMMIT-CHART.
           READ CHART-FILE
                AT END
                   MOVE "T" TO WS-EOF-CHART-SWITCH
                NOT AT END
                   IF CH-ACC-ID = 1
                      ADD WS-SALES-TOTAL TO CH-ACC-BALANCE
                      SUBTRACT WS-EXPENSE-TOTAL FROM CH-ACC-BALANCE
                      REWRITE CHART-INFO
                   END-IF
           END-READ.
       810-COMMIT-CHART-EXIT.
           EXIT.
