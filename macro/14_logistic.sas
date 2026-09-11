%macro logistic_analysis(
    indata=adae,
    outdata=logistic_results
);

    /* 1. Collapse ADAE to subject level: any SAE per subject */
    proc sql;
        create table sae_subj as
        select distinct SUBJID, TRT,
               max(case when SAEFL = "Y" then 1 else 0 end) as SAE_FLAG
        from &indata
        group by SUBJID, TRT;
    quit;

    /* 2. Merge with ADSL to get age and sex */
    proc sort data=sae_subj; by SUBJID; run;
    proc sort data=adsl;     by SUBJID; run;

    data sae_analysis;
        merge sae_subj (in=a) adsl (in=b keep=SUBJID AGE SEX);
        by SUBJID;
        if a;

        label SAE_FLAG = "Serious Adverse Event (1=Yes, 0=No)";
    run;

    /* 3. Logistic regression */
    proc logistic data=sae_analysis descending;
        class TRT (ref="Placebo") SEX (ref="F") / param=ref;
        model SAE_FLAG = TRT AGE SEX / clodds=wald;
        ods output CLOddsWald=&outdata;   /* <-- 修正：表名改为 CLOddsWald */
        title "Logistic Regression - Serious Adverse Events";
    run;

    /* 4. Print results */
    proc print data=&outdata noobs;
        title2 "Odds Ratios for SAE";
    run;

    %put NOTE: ===== Logistic regression completed =====;

%mend logistic_analysis;