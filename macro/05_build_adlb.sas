/* ============================================
   05_build_adlb.sas
   Purpose: Build ADLB (Laboratory Analysis Dataset)
   ============================================ */

%macro build_adlb(
    indata=,
    adsl=adsl,
    outdata=adlb,
    id=SUBJID,
    visit=VISIT,
    visit_date=VISIT_DATE,
    test_code=TEST_CODE,
    test_name=TEST_NAME,
    result=RESULT,
    unit=UNIT,
    ref_low=REFERENCE_LOW,
    ref_high=REFERENCE_HIGH,
    abn_flag=ABNORMAL_FLAG
);

    /* 1. Derive ANRIND and ABLFL */
    data adlb_base;
        set &indata;

        length ANRIND $6;
        if &abn_flag = "H" then ANRIND = "HIGH";
        else if &abn_flag = "L" then ANRIND = "LOW";
        else ANRIND = "NORMAL";

        length ABLFL $1;
        if &visit = "BASELINE" then ABLFL = "Y";
        else ABLFL = "N";

        label ANRIND = "Analysis Normal Range Indicator"
              ABLFL  = "Baseline Record Flag";
    run;

    /* 2. Extract baseline values */
    data adlb_bl;
        set adlb_base;
        where ABLFL = "Y";
        keep &id &test_code ANRIND;
        rename ANRIND = BNRIND;
    run;

    /* 3. Merge baseline back to main dataset */
    proc sort data=adlb_base; by &id &test_code; run;
    proc sort data=adlb_bl;   by &id &test_code; run;

    data &outdata;
        merge adlb_base (in=a) adlb_bl (in=b);
        by &id &test_code;
        if a;

        length SHIFT $20;
        if not missing(BNRIND) and not missing(ANRIND) then
            SHIFT = catx(" to ", BNRIND, ANRIND);
        else SHIFT = "";

        label BNRIND = "Baseline Normal Range Indicator"
              SHIFT  = "Shift from Baseline to Analysis";
    run;

    /* 4. Merge with ADSL to get treatment group */
    proc sort data=&outdata; by &id; run;
    proc sort data=&adsl;    by &id; run;

    data &outdata;
        merge &outdata (in=a) &adsl (in=b keep=&id TRT ARM);
        by &id;
        if a;
    run;

    %put NOTE: ===== ADLB built successfully =====;

%mend build_adlb;