/* ============================================
   09_safety_analysis.sas
   Purpose: Generate safety summary tables for ADAE
   ============================================ */

%macro safety_analysis(
    indata=adae,
    outdata=ae_summary
);

    /* 1. Overall TEAE summary by treatment */
    proc freq data=&indata;
        where TEAE = "Y";
        tables TRT / out=ae_overall_out;
    run;

    /* 2. TEAE by preferred term and treatment */
    proc freq data=&indata;
        where TEAE = "Y";
        tables TRT * AE_TERM / out=ae_term_out nocol norow nopercent;
    run;

    /* 3. TEAE by severity and treatment */
    proc freq data=&indata;
        where TEAE = "Y";
        tables TRT * SEVERITY / out=ae_sev_out nocol norow nopercent;
    run;

    /* 4. Serious TEAE by treatment */
    proc freq data=&indata;
        where TEAE = "Y" and SAEFL = "Y";
        tables TRT / out=ae_sae_out;
    run;

    /* 5. Drug-related TEAE by treatment */
    proc freq data=&indata;
        where TEAE = "Y" and AEREL = "Y";
        tables TRT / out=ae_rel_out;
    run;

    %put NOTE: ===== Safety analysis completed =====;

%mend safety_analysis;