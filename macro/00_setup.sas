/* ============================================
   00_setup.sas
   Purpose: Global configuration - paths and file names
   ============================================ */

%let mypath   = /home/u64589246/ONCO26_data/;
%let dmfile   = raw_dm.csv;
%let survfile = raw_survival.csv;

/* Optional: output directory */
%let outpath  = /home/u64589246/ONCO26_data/;

%put NOTE: ===== Global configuration loaded =====;
%put NOTE: Data path: &mypath;