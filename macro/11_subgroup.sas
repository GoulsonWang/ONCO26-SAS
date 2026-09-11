/* ============================================
   11_subgroup.sas
   Purpose: Derive subgroup variables and run subgroup Cox analysis
   ============================================ */

%macro subgroup_analysis(
    indata=adtte_merged,
    outdata=subgroup_hr
);

    /* 1. Derive subgroup variables */
    data adtte_sub;
        set &indata;

        length AGEGR1 $10;
        if AGE < 65 then AGEGR1 = "<65";
        else AGEGR1 = ">=65";

        length BMIGR1 $10;
        if BMI < 25 then BMIGR1 = "<25";
        else if BMI >= 25 then BMIGR1 = ">=25";
        else BMIGR1 = "Missing";

        length SEXGR1 $1;
        SEXGR1 = SEX;

        label AGEGR1 = "Age Group"
              BMIGR1 = "BMI Group"
              SEXGR1 = "Sex";
    run;

    /* 2. Create empty output dataset */
    data &outdata;
        length Subgroup $20 SubgroupValue $20;
        HazardRatio = .;
        LowerCL = .;
        UpperCL = .;
        stop;
    run;

    /* 3. Run Cox regression within each subgroup */
    %local i grp var;
    %let grp_list = AGEGR1 BMIGR1 SEXGR1;
    %let var_list = Age BMI Sex;

    %do i = 1 %to 3;
        %let grp = %scan(&grp_list, &i);
        %let var = %scan(&var_list, &i);

        /* Get unique subgroup values */
        proc sql noprint;
            select distinct &grp into :grpvals separated by "|"
            from adtte_sub
            where &grp is not missing and &grp ne "Missing";
        quit;

        %local j grpval;
        %do j = 1 %to %sysfunc(countw(&grpvals, |));
            %let grpval = %scan(&grpvals, &j, |);

            proc phreg data=adtte_sub;
                where &grp = "&grpval";
                class ARM (ref="ARM B") / param=ref;
                model AVAL * CNSR(0) = ARM / ties=efron;
                ods output ParameterEstimates=pe_temp;
            run;

            data hr_temp;
                set pe_temp;
                where Parameter = "ARM";
                length Subgroup $20 SubgroupValue $20;
                Subgroup = "&var";
                SubgroupValue = "&grpval";
                HazardRatio = exp(Estimate);
                LowerCL = exp(Estimate - 1.96*StdErr);
                UpperCL = exp(Estimate + 1.96*StdErr);
                keep Subgroup SubgroupValue HazardRatio LowerCL UpperCL;
            run;

            proc append base=&outdata data=hr_temp force;
            run;
        %end;
    %end;

    %put NOTE: ===== Subgroup analysis completed =====;

%mend subgroup_analysis;