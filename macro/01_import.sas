/* ============================================
   01_import.sas
   Purpose: Data import macro
   ============================================ */

%macro import_csv(file=, out=, guess=1000);
    proc import datafile="&mypath.&file"
        out=&out
        dbms=csv
        replace;
        guessingrows=&guess;
    run;
%mend import_csv;