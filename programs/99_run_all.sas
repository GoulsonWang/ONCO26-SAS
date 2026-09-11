%let macrodir = /home/u64589246/ONCO26_code/macro/;

%include "&macrodir.00_setup.sas";
%include "&macrodir.01_import.sas";
%include "&macrodir.02_build_adsl.sas";
%include "&macrodir.03_build_adtte.sas";
%include "&macrodir.04_build_adae.sas";
%include "&macrodir.05_build_adlb.sas";
%include "&macrodir.06_km_analysis.sas";
%include "&macrodir.07_cox_analysis.sas";
%include "&macrodir.09_safety_analysis.sas";
%include "&macrodir.10_lab_analysis.sas";
%include "&macrodir.11_subgroup.sas";
%include "&macrodir.12_forest_plot.sas";
%include "&macrodir.13_ph_assumption.sas";
%include "&macrodir.14_logistic.sas";
%include "&macrodir.08_pipeline.sas";

%onco26_pipeline();