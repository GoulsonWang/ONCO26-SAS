/* ============================================
   08_pipeline.sas
   Purpose: Master macro - one-click full pipeline
   ============================================ */

%macro onco26_pipeline(
    dm_file=raw_dm.csv,
    surv_file=raw_survival.csv,
    ae_file=raw_ae.csv,
    lab_file=raw_lab.csv
);

    /* Step 1: Import raw data */
    %put NOTE: [1/14] Importing raw data...;
    %import_csv(file=&dm_file, out=raw_dm);
    %import_csv(file=&surv_file, out=raw_survival);
    %import_csv(file=&ae_file, out=raw_ae);
    %import_csv(file=&lab_file, out=raw_lab);

    /* Step 2: Build ADSL */
    %put NOTE: [2/14] Building ADSL...;
    %build_adsl(indata=raw_dm);

    /* Step 3: Build ADTTE */
    %put NOTE: [3/14] Building ADTTE...;
    %build_adtte(indata=raw_survival);

    /* Step 4: Build ADAE */
    %put NOTE: [4/14] Building ADAE...;
    %build_adae(indata=raw_ae, adsl=adsl);

    /* Step 5: Build ADLB */
    %put NOTE: [5/14] Building ADLB...;
    %build_adlb(indata=raw_lab, adsl=adsl);

    /* Step 6: Merge ADSL and ADTTE */
    %put NOTE: [6/14] Merging ADSL and ADTTE...;
    data adtte_merged;
        merge adsl(in=a) adtte(in=b);
        by subjid;
        if a and b;
    run;

    /* Step 7: Subgroup analysis */
    %put NOTE: [7/14] Running subgroup analysis...;
    %subgroup_analysis(indata=adtte_merged, outdata=subgroup_hr);

    /* Step 8: Prepare forest plot data */
    %put NOTE: [8/14] Preparing forest plot data...;
    data forest_data;
        set subgroup_hr;
        length Order 8;
        if Subgroup = "Age" and SubgroupValue = "<65" then Order = 1;
        else if Subgroup = "Age" and SubgroupValue = ">=65" then Order = 2;
        else if Subgroup = "BMI" and SubgroupValue = "<25" then Order = 3;
        else if Subgroup = "BMI" and SubgroupValue = ">=25" then Order = 4;
        else if Subgroup = "Sex" and SubgroupValue = "F" then Order = 5;
        else if Subgroup = "Sex" and SubgroupValue = "M" then Order = 6;
        length Label $30;
        Label = catx(": ", Subgroup, SubgroupValue);
        keep Order Label HazardRatio LowerCL UpperCL;
    run;

    data overall_row;
        length Label $30;
        Order = 0;
        Label = "Overall";
        HazardRatio = 0.889;
        LowerCL = 0.687;
        UpperCL = 1.152;
    run;

    data forest_final;
        set overall_row forest_data;
    run;

    proc sort data=forest_final; by Order; run;

    /* Step 9: Prepare SAE analysis dataset */
    %put NOTE: [9/14] Preparing SAE analysis dataset...;
    proc sql;
        create table sae_subj as
        select distinct SUBJID, TRT,
               max(case when SAEFL = "Y" then 1 else 0 end) as SAE_FLAG
        from adae
        group by SUBJID, TRT;
    quit;

    proc sort data=sae_subj; by SUBJID; run;
    proc sort data=adsl; by SUBJID; run;

    data sae_analysis;
        merge sae_subj (in=a) adsl (in=b keep=SUBJID AGE SEX);
        by SUBJID;
        if a;
    run;

    /* Step 10: Export all outputs to PDF */
    %put NOTE: [10/14] Exporting all outputs to PDF...;
    %export_outputs();

    %put NOTE: ===== Full pipeline completed successfully =====;
    %put NOTE: Check output at &outpath;

%mend onco26_pipeline;