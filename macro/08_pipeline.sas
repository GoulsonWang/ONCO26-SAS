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
    %put NOTE: [1/13] Importing raw data...;
    %import_csv(file=&dm_file, out=raw_dm);
    %import_csv(file=&surv_file, out=raw_survival);
    %import_csv(file=&ae_file, out=raw_ae);
    %import_csv(file=&lab_file, out=raw_lab);

    /* Step 2: Build ADSL */
    %put NOTE: [2/13] Building ADSL...;
    %build_adsl(indata=raw_dm);

    /* Step 3: Build ADTTE */
    %put NOTE: [3/13] Building ADTTE...;
    %build_adtte(indata=raw_survival);

    /* Step 4: Build ADAE */
    %put NOTE: [4/13] Building ADAE...;
    %build_adae(indata=raw_ae, adsl=adsl);

    /* Step 5: Build ADLB */
    %put NOTE: [5/13] Building ADLB...;
    %build_adlb(indata=raw_lab, adsl=adsl);

    /* Step 6: Merge ADSL and ADTTE */
    %put NOTE: [6/13] Merging ADSL and ADTTE...;
    data adtte_merged;
        merge adsl(in=a) adtte(in=b);
        by subjid;
        if a and b;
    run;

    /* Step 7: KM survival analysis */
    %put NOTE: [7/13] Running KM survival analysis...;
    %km_analysis(indata=adtte);

    /* Step 8: Cox regression */
    %put NOTE: [8/13] Running Cox regression...;
    %cox_analysis(indata=adtte_merged);

    /* Step 9: Subgroup analysis */
    %put NOTE: [9/13] Running subgroup analysis...;
    %subgroup_analysis(indata=adtte_merged, outdata=subgroup_hr);

    /* Step 10: Forest plot */
    %put NOTE: [10/13] Generating forest plot...;
    %forest_plot(indata=subgroup_hr);

    /* Step 11: PH assumption test */
    %put NOTE: [11/13] Testing PH assumption...;
    %ph_assumption(indata=adtte_merged);

    /* Step 12: Safety analysis */
    %put NOTE: [12/13] Running safety analysis...;
    %safety_analysis(indata=adae);

    /* Step 13: Lab and logistic analysis */
    %put NOTE: [13/13] Running lab and logistic analysis...;
    %lab_analysis(indata=adlb);
    %logistic_analysis(indata=adae, outdata=logistic_results);

    %put NOTE: ===== Full pipeline completed successfully =====;

%mend onco26_pipeline;