/* ============================================
   04_build_adae.sas
   Purpose: Build ADAE (Adverse Event Analysis Dataset)
   ============================================ */

%macro build_adae(
    indata=,
    adsl=adsl,
    outdata=adae,
    id=SUBJID,
    ae_term=AE_TERM,
    ae_start=AE_START_DATE,
    ae_end=AE_END_DATE,
    severity=SEVERITY,
    serious=SERIOUS_FLAG,
    related=RELATED_TO_TREATMENT,
    outcome=OUTCOME
);

    /* Sort both datasets by subject ID */
    proc sort data=&indata; by &id; run;
    proc sort data=&adsl;   by &id; run;

    /* Merge AE with ADSL and derive analysis flags */
    data &outdata;
        merge &indata (in=a) &adsl (in=b keep=&id TRT ARM TRTSDT);
        by &id;
        if a;

        /* 1. TEAE flag: AE started on/after treatment start */
        length TEAE $1;
        if &ae_start >= TRTSDT and not missing(&ae_start) then TEAE = "Y";
        else TEAE = "N";

        /* 2. Numeric severity for sorting */
        length AESEVN $1;
        if &severity = "Mild"          then AESEVN = "1";
        else if &severity = "Moderate" then AESEVN = "2";
        else if &severity = "Severe"   then AESEVN = "3";
        else AESEVN = "9";

        /* 3. Serious AE flag */
        length SAEFL $1;
        if &serious = "Y" then SAEFL = "Y";
        else SAEFL = "N";

        /* 4. Related AE flag */
        length AEREL $1;
        if &related = "Y" then AEREL = "Y";
        else AEREL = "N";

        /* 5. Add labels */
        label TEAE   = "Treatment-Emergent Adverse Event Flag"
              AESEVN = "Severity (Numeric)"
              SAEFL  = "Serious Adverse Event Flag"
              AEREL  = "Related to Treatment Flag";

    run;

    %put NOTE: ===== ADAE built successfully =====;

%mend build_adae;