/* ============================================
   12_forest_plot.sas
   Purpose: Generate forest plot for subgroup analysis
   ============================================ */

%macro forest_plot(
    indata=subgroup_hr,
    overall_hr=0.889,
    overall_lower=0.687,
    overall_upper=1.152,
    outpath=/home/u64589246/ONCO26_data/,
    outfile=Forest_Plot.png
);

    /* 1. Prepare subgroup data */
    data forest_data;
        set &indata;

        length Order 8;
        if Subgroup = "Age" and SubgroupValue = "<65"   then Order = 1;
        else if Subgroup = "Age" and SubgroupValue = ">=65" then Order = 2;
        else if Subgroup = "BMI" and SubgroupValue = "<25"  then Order = 3;
        else if Subgroup = "BMI" and SubgroupValue = ">=25" then Order = 4;
        else if Subgroup = "Sex" and SubgroupValue = "F"    then Order = 5;
        else if Subgroup = "Sex" and SubgroupValue = "M"    then Order = 6;

        length Label $30;
        Label = catx(": ", Subgroup, SubgroupValue);

        keep Order Label HazardRatio LowerCL UpperCL;
    run;

    /* Add overall row at top - with explicit length for Label */
    data overall_row;
        length Label $30;    /* <-- 新增这一行，修复 WARNING */
        Order = 0;
        Label = "Overall";
        HazardRatio = &overall_hr;
        LowerCL = &overall_lower;
        UpperCL = &overall_upper;
    run;

    data forest_final;
        set overall_row forest_data;
    run;

    proc sort data=forest_final; by Order; run;

    /* 2. Generate forest plot */
    ods graphics on / width=800px height=400px;

    proc sgplot data=forest_final noautolegend;
        refline 1 / axis=x lineattrs=(color=gray pattern=dash);

        scatter y=Label x=HazardRatio / 
            xerrorlower=LowerCL 
            xerrorupper=UpperCL
            markerattrs=(symbol=squarefilled size=8 color=steelblue)
            errorbarattrs=(color=steelblue thickness=2);

        xaxis label="Hazard Ratio (95% CI)" 
              values=(0 to 2 by 0.5) 
              grid;
        yaxis label="" 
              fitpolicy=none
              discreteorder=data;

        title "Forest Plot - Subgroup Analysis of Overall Survival";
        footnote "HR < 1 favors ARM A (Active); HR > 1 favors ARM B (Placebo)";
    run;

    ods graphics off;

    %put NOTE: ===== Forest plot completed =====;

%mend forest_plot;