/* ============================================
   06_km_analysis.sas
   Purpose: Kaplan-Meier survival analysis macro
   ============================================ */

%macro km_analysis(
    indata=,
    time=AVAL,
    cnsr=CNSR,
    strata=ARM,
    event_code=0,
    time_min=0,
    time_max=800,
    time_by=100
);

    proc lifetest data=&indata
        plots=survival(atrisk=&time_min to &time_max by &time_by)
        notable;
        
        time &time * &cnsr(&event_code);
        strata &strata;
    run;

    %put NOTE: ===== KM survival analysis completed =====;

%mend km_analysis;