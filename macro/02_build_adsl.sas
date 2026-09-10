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
    arm_placebo=ARM B
);

    data &outdata;
        set &indata;
        
        length TRT $10;
        if &arm = "&arm_active" then TRT = "Active";
        else if &arm = "&arm_placebo" then TRT = "Placebo";
        else TRT = "Unknown";
        
        label &id  = "Subject Identifier"
              &age = "Age (years)"
              &sex = "Sex"
              &race = "Race"
              &bmi = "Body Mass Index (kg/m2)"
              &arm = "Treatment Arm (Raw)"
              TRT  = "Treatment Group (Derived)";
        
        keep &id &age &sex &race &bmi &arm TRT;
    run;

%mend build_adsl;