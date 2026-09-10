/* ============================================
   09_safety_analysis.sas
   Purpose: Generate formatted safety summary tables
   ============================================ */

%macro safety_analysis(
    indata=adae,
    outpath=&outpath,
    outfile=Safety_Summary.rtf
);

    /* ---- 1. Prepare TEAE summary data ---- */

    /* TEAE by preferred term (PT) and treatment */
    proc freq data=&indata noprint;
        where TEAE = "Y";
        tables AE_TERM * TRT / out=ae_pt_out;
    run;

    /* TEAE by severity and treatment */
    proc freq data=&indata noprint;
        where TEAE = "Y";
        tables SEVERITY * TRT / out=ae_sev_out;
    run;

    /* Overall TEAE count */
    proc freq data=&indata noprint;
        where TEAE = "Y";
        tables TRT / out=ae_overall_out;
    run;

    /* SAE count */
    proc freq data=&indata noprint;
        where TEAE = "Y" and SAEFL = "Y";
        tables TRT / out=ae_sae_out;
    run;

    /* Related TEAE count */
    proc freq data=&indata noprint;
        where TEAE = "Y" and AEREL = "Y";
        tables TRT / out=ae_rel_out;
    run;

    /* ---- 2. Generate formatted RTF output ---- */

    ods rtf file="&outpath.&outfile" style=journal;

    title "Safety Summary - Treatment-Emergent Adverse Events (TEAE)";
    footnote "Source: ADAE dataset";

    /* Table 1: Overall TEAE summary */
    proc report data=ae_overall_out nowd headline headskip;
        column TRT COUNT PERCENT;
        define TRT     / display "Treatment Group";
        define COUNT   / display "N of TEAE";
        define PERCENT / display "Percent (%)" format=5.2;
        title2 "Overall TEAE by Treatment Group";
    run;

    /* Table 2: TEAE by preferred term */
    proc report data=ae_pt_out nowd headline headskip;
        column AE_TERM TRT,COUNT TRT,PERCENT;
        define AE_TERM     / group "Adverse Event Term";
        define TRT         / across "Treatment Group";
        define COUNT       / analysis sum "N" format=5.0;
        define PERCENT     / analysis sum "Percent (%)" format=5.2;
        title2 "TEAE by Preferred Term and Treatment";
    run;

    /* Table 3: TEAE by severity */
    proc report data=ae_sev_out nowd headline headskip;
        column SEVERITY TRT,COUNT TRT,PERCENT;
        define SEVERITY    / group "Severity";
        define TRT         / across "Treatment Group";
        define COUNT       / analysis sum "N" format=5.0;
        define PERCENT     / analysis sum "Percent (%)" format=5.2;
        title2 "TEAE by Severity and Treatment";
    run;

    ods rtf close;

    %put NOTE: ===== Safety analysis completed =====;
    %put NOTE: Output file: &outpath.&outfile;

%mend safety_analysis;
