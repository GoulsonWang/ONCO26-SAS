/* ============================================
   03_build_adtte.sas
   Purpose: Build ADTTE (Time-to-Event Analysis Dataset)
   ============================================ */

%macro build_adtte(
    indata=,
    outdata=adtte,
    id=SUBJID,
    time=OS_DAYS,
    event=EVENT_STATUS,
    paramcd=OS,
    param=Overall Survival,
    arm=ARM
);

    data &outdata;
        set &indata;
        
        AVAL = &time;
        CNSR = 1 - &event;
        PARAMCD = "&paramcd";
        PARAM = "&param";
        
        length EVNTDESC $20;
        if &event = 1 then EVNTDESC = "DEATH";
        else EVNTDESC = "CENSORED";
        
        label AVAL     = "Analysis Value (Survival Days)"
              CNSR     = "Censoring Indicator (0=Event, 1=Censored)"
              PARAMCD  = "Parameter Code"
              PARAM    = "Parameter Description"
              EVNTDESC = "Event/Censoring Description";
        
        keep &id AVAL CNSR PARAMCD PARAM EVNTDESC &arm;
    run;

%mend build_adtte;