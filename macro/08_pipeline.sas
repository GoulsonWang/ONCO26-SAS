/* ============================================
   08_pipeline.sas
   Purpose: Master macro - one-click full pipeline
   ============================================ */

%macro onco26_pipeline(
    dm_file=raw_dm.csv,
    surv_file=raw_survival.csv
);

    %put NOTE: [1/6] Importing raw data...;
    %import_csv(file=&dm_file, out=raw_dm);
    %import_csv(file=&surv_file, out=raw_survival);

    %put NOTE: [2/6] Building ADSL...;
    %build_adsl(indata=raw_dm);

    %put NOTE: [3/6] Building ADTTE...;
    %build_adtte(indata=raw_survival);

    %put NOTE: [4/6] Merging ADSL and ADTTE...;
    data adtte_merged;
        merge adsl(in=a) adtte(in=b);
        by subjid;
        if a and b;
    run;

    %put NOTE: [5/6] Running KM survival analysis...;
    %km_analysis(indata=adtte);

    %put NOTE: [6/6] Running Cox regression...;
    %cox_analysis(indata=adtte_merged);

    %put NOTE: ===== Full pipeline completed successfully =====;

%mend onco26_pipeline;