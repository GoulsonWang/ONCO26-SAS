/* ============================================
   02_build_adsl.sas
   Purpose: Build ADSL (Subject-Level Analysis Dataset)
   ============================================ */

%macro build_adsl(
    indata=,
    outdata=adsl,
    id=SUBJID,
    age=AGE,
    sex=SEX,
    race=RACE,
    bmi=BMI,
    arm=ARM,
    arm_active=ARM A,
    arm_placebo=ARM B,
    trtsdt_var=TREATMENT_START_DATE
);

    data &outdata;
        set &indata;
        
        length TRT $10;
        if &arm = "&arm_active" then TRT = "Active";
        else if &arm = "&arm_placebo" then TRT = "Placebo";
        else TRT = "Unknown";
        
        /* Derive treatment start date (TRTSDT) */
        TRTSDT = &trtsdt_var;
        
        label &id    = "Subject Identifier"
              &age   = "Age (years)"
              &sex   = "Sex"
              &race  = "Race"
              &bmi   = "Body Mass Index (kg/m2)"
              &arm   = "Treatment Arm (Raw)"
              TRT    = "Treatment Group (Derived)"
              TRTSDT = "Treatment Start Date";
        
        keep &id &age &sex &race &bmi &arm TRT TRTSDT;
    run;

%mend build_adsl;
