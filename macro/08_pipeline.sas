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
    %put NOTE: [1/7] Importing raw data...;
    %import_csv(file=&dm_file, out=raw_dm);
    %import_csv(file=&surv_file, out=raw_survival);
    %import_csv(file=&ae_file, out=raw_ae);

    /* Step 2: Build ADSL */
    %put NOTE: [2/7] Building ADSL...;
    %build_adsl(indata=raw_dm);

    /* Step 3: Build ADTTE */
    %put NOTE: [3/7] Building ADTTE...;
    %build_adtte(indata=raw_survival);

    /* Step 4: Build ADAE */
    %put NOTE: [4/7] Building ADAE...;
    %build_adae(indata=raw_ae, adsl=adsl);

    /* Step 5: Merge ADSL and ADTTE */
    %put NOTE: [5/7] Merging ADSL and ADTTE...;
    data adtte_merged;
        merge adsl(in=a) adtte(in=b);
        by subjid;
        if a and b;
    run;

    /* Step 6: KM survival analysis */
    %put NOTE: [6/7] Running KM survival analysis...;
    %km_analysis(indata=adtte);

    /* Step 7: Cox regression */
    %put NOTE: [7/7] Running Cox regression...;
    %cox_analysis(indata=adtte_merged);

    %put NOTE: ===== Full pipeline completed successfully =====;

%mend onco26_pipeline;
