/* ============================================
   10_lab_analysis.sas
   Purpose: Generate Shift Table for ADLB
   ============================================ */

%macro lab_analysis(
    indata=adlb,
    outpath=&outpath,
    outfile=Lab_Shift_Table.rtf
);

    /* 1. Prepare shift table data: by visit and treatment */
    proc freq data=&indata noprint;
        where VISIT ne "BASELINE";
        tables VISIT * TRT * BNRIND * ANRIND / out=shift_out;
    run;

    /* 2. Prepare overall shift table (collapsed across visits) */
    proc freq data=&indata noprint;
        where VISIT ne "BASELINE";
        tables TRT * BNRIND * ANRIND / out=shift_overall;
    run;

    /* 3. Generate formatted RTF output */
    ods rtf file="&outpath.&outfile" style=journal;

    title "Laboratory Shift Table - Baseline to Post-Baseline";
    footnote "Source: ADLB dataset";

    /* Table 1: Overall shift table by treatment */
    proc report data=shift_overall nowd headline headskip;
        column TRT BNRIND ANRIND COUNT PERCENT;
        define TRT     / group "Treatment Group";
        define BNRIND  / group "Baseline Status";
        define ANRIND  / group "Post-Baseline Status";
        define COUNT   / analysis sum "N" format=5.0;
        define PERCENT / analysis sum "Percent (%)" format=5.2;
        title2 "Overall Shift from Baseline to Post-Baseline";
    run;

    /* Table 2: Shift by visit */
    proc report data=shift_out nowd headline headskip;
        column VISIT TRT BNRIND ANRIND COUNT;
        define VISIT   / group "Visit";
        define TRT     / group "Treatment Group";
        define BNRIND  / group "Baseline Status";
        define ANRIND  / group "Post-Baseline Status";
        define COUNT   / analysis sum "N" format=5.0;
        title2 "Shift by Visit and Treatment";
    run;

    ods rtf close;

    %put NOTE: ===== Lab analysis completed =====;
    %put NOTE: Output file: &outpath.&outfile;

%mend lab_analysis;