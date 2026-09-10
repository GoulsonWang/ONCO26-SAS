/* ============================================
   07_cox_analysis.sas
   Purpose: Cox proportional hazards regression macro
   ============================================ */

%macro cox_analysis(
    indata=,
    time=AVAL,
    cnsr=CNSR,
    event_code=0,
    trt_var=ARM,
    trt_ref=ARM B,
    sex_var=SEX,
    sex_ref=F,
    covariates=age sex bmi,
    ties=efron
);

    proc phreg data=&indata;
        class &trt_var (ref="&trt_ref")
              &sex_var (ref="&sex_ref") / param=ref;
        
        model &time * &cnsr(&event_code) = &trt_var &covariates / ties=&ties;
        
        hazardratio &trt_var / diff=ref;
        
        ods output ParameterEstimates=cox_params
                   HazardRatios=cox_hr;
    run;

    %put NOTE: ===== Cox regression analysis completed =====;

%mend cox_analysis;