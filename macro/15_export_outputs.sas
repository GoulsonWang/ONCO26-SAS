/* ============================================
   15_export_outputs.sas
   Purpose: Automatically export all analysis outputs
            (figures and tables) to PDF and PNG files
   ============================================ */

%macro export_outputs(
    outpath=/home/u64589246/ONCO26_data/output/,
    outfile=ONCO26_All_Outputs.pdf
);

    /* Create output directory if needed */
    options dlcreatedir;
    libname _outdir "&outpath";
    libname _outdir clear;

    /* ===== Section 1: Survival Analysis ===== */

    ods pdf file="&outpath.&outfile" style=journal
        startpage=no;

    ods graphics on / width=800px height=500px outputfmt=png
        imagename="KM_Curve" imagefmt=png;

    /* Title page */
    ods escapechar='^';
    title height=18pt "ONCO26 Oncology Phase III Clinical Trial";
    title2 height=14pt "Complete Analysis Report";
    title3 height=10pt "Generated on %sysfunc(today(), worddate.)";

    proc odstext;
        p "This report contains the complete statistical analysis outputs for the ONCO26 simulated Phase III clinical trial, including survival analysis, subgroup analysis, safety analysis, and laboratory shift analysis.";
    run;

    title;

    /* ---- 1.1 Kaplan-Meier Curve ---- */
    title "Figure 1. Kaplan-Meier Survival Curve by Treatment Group";
    proc lifetest data=adtte plots=survival(atrisk=0 to 800 by 100) notable;
        time AVAL * CNSR(0);
        strata ARM;
    run;

    /* ---- 1.2 KM Quartile Estimates ---- */
    title "Table 1. Median Survival Time by Treatment Group";
    proc lifetest data=adtte notable;
        time AVAL * CNSR(0);
        strata ARM;
    run;

    /* ---- 1.3 Cox Regression Results ---- */
    title "Table 2. Cox Proportional Hazards Regression Results";
    proc phreg data=adtte_merged;
        class ARM (ref="ARM B") sex (ref="F") / param=ref;
        model AVAL * CNSR(0) = ARM age sex bmi / ties=efron;
        hazardratio ARM / diff=ref;
    run;

    /* ---- 1.4 PH Assumption Test ---- */
    title "Table 3. Proportional Hazards Assumption Test";
    proc phreg data=adtte_merged;
        class ARM (ref="ARM B") sex (ref="F") / param=ref;
        model AVAL * CNSR(0) = ARM age sex bmi / ties=efron;
        assess ph / resample seed=12345;
    run;

    /* ===== Section 2: Subgroup Analysis ===== */

    /* ---- 2.1 Subgroup Forest Plot ---- */
    title "Figure 2. Forest Plot of Subgroup Analysis";
    proc sgplot data=forest_final noautolegend;
        refline 1 / axis=x lineattrs=(color=gray pattern=dash);
        scatter y=Label x=HazardRatio /
            xerrorlower=LowerCL
            xerrorupper=UpperCL
            markerattrs=(symbol=squarefilled size=8 color=steelblue)
            errorbarattrs=(color=steelblue thickness=2);
        xaxis label="Hazard Ratio (95% CI)" values=(0 to 2 by 0.5) grid;
        yaxis label="" fitpolicy=none discreteorder=data;
    run;

    /* ---- 2.2 Subgroup HR Table ---- */
    title "Table 4. Subgroup Analysis - Hazard Ratios";
    proc print data=subgroup_hr noobs label;
        var Subgroup SubgroupValue HazardRatio LowerCL UpperCL;
        label HazardRatio = "Hazard Ratio"
              LowerCL = "95% CI Lower"
              UpperCL = "95% CI Upper";
    run;

    /* ===== Section 3: Safety Analysis ===== */

    title "Section 3. Safety Analysis";

    /* ---- 3.1 Overall TEAE Summary ---- */
    title2 "Table 5. Overall TEAE Summary by Treatment Group";
    proc freq data=adae noprint;
        where TEAE = "Y";
        tables TRT / out=ae_overall_out;
    run;

    proc report data=ae_overall_out nowd headline headskip;
        column TRT COUNT PERCENT;
        define TRT / display "Treatment Group";
        define COUNT / display "N of TEAE";
        define PERCENT / display "Percent (%)" format=5.2;
    run;

    /* ---- 3.2 TEAE by Preferred Term ---- */
    title2 "Table 6. TEAE by Preferred Term";
    proc freq data=adae noprint;
        where TEAE = "Y";
        tables AE_TERM * TRT / out=ae_pt_out;
    run;

    proc report data=ae_pt_out nowd headline headskip;
        column AE_TERM TRT,COUNT TRT,PERCENT;
        define AE_TERM / group "Adverse Event Term";
        define TRT / across "Treatment Group";
        define COUNT / analysis sum "N" format=5.0;
        define PERCENT / analysis sum "Percent (%)" format=5.2;
    run;

    /* ---- 3.3 TEAE by Severity ---- */
    title2 "Table 7. TEAE by Severity and Treatment";
    proc freq data=adae noprint;
        where TEAE = "Y";
        tables SEVERITY * TRT / out=ae_sev_out;
    run;

    proc report data=ae_sev_out nowd headline headskip;
        column SEVERITY TRT,COUNT TRT,PERCENT;
        define SEVERITY / group "Severity";
        define TRT / across "Treatment Group";
        define COUNT / analysis sum "N" format=5.0;
        define PERCENT / analysis sum "Percent (%)" format=5.2;
    run;

    /* ---- 3.4 SAE and Related AE Summary ---- */
    title2 "Table 8. Serious and Drug-Related TEAE Summary";
    proc freq data=adae noprint;
        where TEAE = "Y";
        tables SAEFL * TRT / out=ae_sae_out;
    run;

    proc report data=ae_sae_out nowd headline headskip;
        column SAEFL TRT,COUNT TRT,PERCENT;
        define SAEFL / group "SAE Flag";
        define TRT / across "Treatment Group";
        define COUNT / analysis sum "N" format=5.0;
        define PERCENT / analysis sum "Percent (%)" format=5.2;
    run;

    /* ---- 3.5 Logistic Regression for SAE ---- */
    title2 "Table 9. Logistic Regression - Serious Adverse Events";
    proc logistic data=sae_analysis descending;
        class TRT (ref="Placebo") SEX (ref="F") / param=ref;
        model SAE_FLAG = TRT AGE SEX / clodds=wald;
    run;

    /* ===== Section 4: Lab Shift Analysis ===== */

    title "Section 4. Laboratory Shift Analysis";

    title2 "Table 10. Shift from Baseline to Post-Baseline (Overall)";
    proc freq data=adlb noprint;
        where VISIT ne "BASELINE";
        tables TRT * BNRIND * ANRIND / out=shift_overall;
    run;

    proc report data=shift_overall nowd headline headskip;
        column TRT BNRIND ANRIND COUNT PERCENT;
        define TRT / group "Treatment Group";
        define BNRIND / group "Baseline Status";
        define ANRIND / group "Post-Baseline Status";
        define COUNT / analysis sum "N" format=5.0;
        define PERCENT / analysis sum "Percent (%)" format=5.2;
    run;

    title2 "Table 11. Shift by Visit and Treatment";
    proc freq data=adlb noprint;
        where VISIT ne "BASELINE";
        tables VISIT * TRT * BNRIND * ANRIND / out=shift_by_visit;
    run;

    proc report data=shift_by_visit nowd headline headskip;
        column VISIT TRT BNRIND ANRIND COUNT;
        define VISIT / group "Visit";
        define TRT / group "Treatment Group";
        define BNRIND / group "Baseline Status";
        define ANRIND / group "Post-Baseline Status";
        define COUNT / analysis sum "N" format=5.0;
    run;

    ods graphics off;
    ods pdf close;

    %put NOTE: ===== All outputs exported =====;
    %put NOTE: Output PDF: &outpath.&outfile;

%mend export_outputs;