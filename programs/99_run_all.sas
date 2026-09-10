/* ============================================
   99_run_all.sas
   Purpose: Run the full pipeline
   ============================================ */

/* Define the directory containing macro files */
%let macrodir = /home/u64589246/ONCO26_code/macro/;

/* Load all macro definitions in order */
%include "&macrodir.00_setup.sas";
%include "&macrodir.01_import.sas";
%include "&macrodir.02_build_adsl.sas";
%include "&macrodir.03_build_adtte.sas";
%include "&macrodir.06_km_analysis.sas";
%include "&macrodir.07_cox_analysis.sas";
%include "&macrodir.08_pipeline.sas";

/* Execute the full pipeline */
%onco26_pipeline();