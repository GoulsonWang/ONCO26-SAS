/* ============================================
   08_pipeline.sas
   Purpose: Master macro - one-click full pipeline
   ============================================ */

%macro onco26_pipeline(
    dm_file=raw_dm.csv,
    surv_file=raw_survival.csv,
    ae_file=raw_ae.csv
);

    /* Step 1: Import raw data */
    %put NOTE: [1/8] Importing raw data...;
    %import_csv(file=&dm_file, out=raw_dm);
    %import_csv(file=&surv_file, out=raw_survival);
    %import_csv(file=&ae_file, out=raw_ae);

    /* Step 2: Build ADSL */
    %put NOTE: [2/8] Building ADSL...;
    %build_adsl(indata=raw_dm);

    /* Step 3: Build ADTTE */
    %put NOTE: [3/8] Building ADTTE...;
    %build_adtte(indata=raw_survival);

    /* Step 4: Build ADAE */
    %put NOTE: [4/8] Building ADAE...;
    %build_adae(indata=raw_ae, adsl=adsl);

    /* Step 5: Merge ADSL and ADTTE */
    %put NOTE: [5/8] Merging ADSL and ADTTE...;
    data adtte_merged;
        merge adsl(in=a) adtte(in=b);
        by subjid;
        if a and b;
    run;

    /* Step 6: KM survival analysis */
    %put NOTE: [6/8] Running KM survival analysis...;
    %km_analysis(indata=adtte);

    /* Step 7: Cox regression */
    %put NOTE: [7/8] Running Cox regression...;
    %cox_analysis(indata=adtte_merged);

    /* Step 8: Safety analysis */
    %put NOTE: [8/8] Running safety analysis...;
    %safety_analysis(indata=adae);

    %put NOTE: ===== Full pipeline completed successfully =====;

%mend onco26_pipeline;
