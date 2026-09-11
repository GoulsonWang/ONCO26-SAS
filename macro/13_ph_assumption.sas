/* ============================================
   13_ph_assumption.sas
   Purpose: Test proportional hazards assumption
   ============================================ */

%macro ph_assumption(
    indata=adtte_merged,
    time=AVAL,
    cnsr=CNSR,
    trt_var=ARM,
    covariates=age sex bmi
);

    /* Test PH assumption using ASSESS statement */
    proc phreg data=&indata;
        class &trt_var (ref="ARM B") sex (ref="F") / param=ref;
        
        model &time * &cnsr(0) = &trt_var &covariates / ties=efron;
        
        /* ASSESS statement: test PH assumption */
        assess ph / resample seed=12345;
        
        title "Proportional Hazards Assumption Test";
        title2 "Supremum Test for PH Assumption";
    run;

    %put NOTE: ===== PH assumption test completed =====;
    %put NOTE: If p-value > 0.05, PH assumption is satisfied;

%mend ph_assumption;