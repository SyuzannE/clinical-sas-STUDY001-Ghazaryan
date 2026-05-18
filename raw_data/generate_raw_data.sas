/* ============================================================
   GENERATE_RAW_DATA.SAS
   Creates fully simulated source data for STUDY001.
   Produces 4 CSV files in &rawpath.:
     demographics.csv  vitals.csv  adverse_events.csv  exposure.csv
   Author : Syuzanna Ghazaryan | Gurus LLC Internship 2026
   ============================================================ */

%INCLUDE "&rootpath./setup.sas" / NOSOURCE;

/* ── Reproducibility seed ────────────────────────────────────── */
%LET seed = 20260101;

/* ────────────────────────────────────────────────────────────────
   1. DEMOGRAPHICS  (60 subjects, 2 arms)
   ──────────────────────────────────────────────────────────────── */
DATA work.raw_demographics;
  LENGTH SUBJID $10 SEX $1 RACE $40 COUNTRY $3 ARM $20;
  ARRAY ages{60};
  FORMAT BRTHDTC RFICDTC RFSTDTC $10.;

  DO i = 1 TO 60;
    SUBJID   = CATS('SUBJ', PUT(i, Z3.));     /* SUBJ001 … SUBJ060 */
    SEX      = IFC(RANUNI(&seed.) < 0.5, 'M', 'F');
    AGE      = 25 + FLOOR(RANUNI(&seed.) * 50); /* 25-74 */

    /* Race distribution */
    IF RANUNI(&seed.) < 0.70      THEN RACE = 'White';
    ELSE IF RANUNI(&seed.) < 0.85 THEN RACE = 'Asian';
    ELSE                               RACE = 'Other';

    COUNTRY  = 'ARM';

    /* Randomisation: odd = Drug A, even = Placebo */
    IF MOD(i,2)=1 THEN ARM = 'Drug A';
    ELSE               ARM = 'Placebo';

    /* Dates (ISO 8601 text) */
    BRTHDTC  = PUT(MDY(1,1,2026-AGE), YYMMDD10.);
    RFICDTC  = PUT(MDY(1,15,2026), YYMMDD10.);     /* Informed consent */
    RFSTDTC  = PUT(MDY(2,1,2026), YYMMDD10.);      /* First dose */

    OUTPUT;
  END;
  DROP i;
RUN;

PROC EXPORT DATA=work.raw_demographics
  OUTFILE="&rawpath./demographics.csv"
  DBMS=CSV REPLACE; RUN;

/* ────────────────────────────────────────────────────────────────
   2. VITAL SIGNS  (6 visits × 5 parameters × 60 subjects)
   ──────────────────────────────────────────────────────────────── */
DATA work.raw_vitals;
  LENGTH SUBJID $10 VISIT $20;
  FORMAT VSDTC $10.;

  ARRAY visit_names{6} $20 _TEMPORARY_
    ('Screening' 'Baseline' 'Week 2' 'Week 4' 'Week 8' 'End of Study');
  ARRAY visit_nums{6} _TEMPORARY_ (0 1 2 3 4 5);
  ARRAY visit_days{6} _TEMPORARY_ (-14 0 14 28 56 60);

  DO subj = 1 TO 60;
    SUBJID = CATS('SUBJ', PUT(subj, Z3.));

    /* Baseline SBP: Drug A arm gets slightly lower over time (treatment effect) */
    base_sbp = 140 + RANNOR(&seed.) * 10;
    base_dbp =  85 + RANNOR(&seed.) *  6;
    base_hr  =  72 + RANNOR(&seed.) *  8;
    base_wt  =  75 + RANNOR(&seed.) * 12;
    ht       = 165 + RANNOR(&seed.) * 10;   /* Height constant */

    trt_effect = IFC(MOD(subj,2)=1, -1.2, -0.2);  /* Drug A vs Placebo */

    DO v = 1 TO 6;
      VISIT    = visit_names{v};
      VISITNUM = visit_nums{v};
      VSDTC    = PUT(MDY(2,1,2026) + visit_days{v}, YYMMDD10.);

      SYSBP  = ROUND(base_sbp + trt_effect * visit_days{v} + RANNOR(&seed.) * 3, 0.1);
      DIABP  = ROUND(base_dbp + trt_effect * visit_days{v} * 0.5 + RANNOR(&seed.) * 2, 0.1);
      HR     = ROUND(base_hr  + RANNOR(&seed.) * 3, 0.1);
      WEIGHT = ROUND(base_wt  + RANNOR(&seed.) * 0.3, 0.1);
      HEIGHT = ROUND(ht, 0.1);

      OUTPUT;
    END;
  END;
  DROP subj v base_: trt_effect ht;
RUN;

PROC EXPORT DATA=work.raw_vitals
  OUTFILE="&rawpath./vitals.csv"
  DBMS=CSV REPLACE; RUN;

/* ────────────────────────────────────────────────────────────────
   3. ADVERSE EVENTS
   ──────────────────────────────────────────────────────────────── */
DATA work.raw_ae;
  LENGTH SUBJID $10 AETERM $60 AESEV $8 AEREL $20 AEOUT $30;
  FORMAT AESTDTC AEENDTC $10.;

  ARRAY ae_terms{8} $60 _TEMPORARY_
    ('Headache' 'Nausea' 'Dizziness' 'Fatigue'
     'Upper respiratory infection' 'Insomnia' 'Back pain' 'Rash');
  ARRAY sev_vals{3} $8 _TEMPORARY_ ('MILD' 'MODERATE' 'SEVERE');
  ARRAY rel_vals{3} $20 _TEMPORARY_
    ('NOT RELATED' 'POSSIBLY RELATED' 'PROBABLY RELATED');
  ARRAY out_vals{3} $30 _TEMPORARY_
    ('RECOVERED/RESOLVED' 'RECOVERING/RESOLVING' 'NOT RECOVERED/NOT RESOLVED');

  DO subj = 1 TO 60;
    SUBJID = CATS('SUBJ', PUT(subj, Z3.));
    n_ae = FLOOR(RANUNI(&seed.) * 4);   /* 0-3 AEs per subject */

    DO ae_i = 1 TO n_ae;
      AETERM   = ae_terms{1 + FLOOR(RANUNI(&seed.) * 8)};
      AESEV    = sev_vals{1 + FLOOR(RANUNI(&seed.) * 3)};
      AEREL    = rel_vals{1 + FLOOR(RANUNI(&seed.) * 3)};
      AEOUT    = out_vals{1 + FLOOR(RANUNI(&seed.) * 3)};
      AESER    = IFC(RANUNI(&seed.) < 0.05, 'Y', 'N');  /* 5% serious */

      start_day = 1 + FLOOR(RANUNI(&seed.) * 55);
      dur_days  = 1 + FLOOR(RANUNI(&seed.) * 20);
      AESTDTC  = PUT(MDY(2,1,2026) + start_day, YYMMDD10.);
      AEENDTC  = PUT(MDY(2,1,2026) + start_day + dur_days, YYMMDD10.);

      OUTPUT;
    END;
  END;
  DROP subj ae_i n_ae start_day dur_days;
RUN;

PROC EXPORT DATA=work.raw_ae
  OUTFILE="&rawpath./adverse_events.csv"
  DBMS=CSV REPLACE; RUN;

/* ────────────────────────────────────────────────────────────────
   4. EXPOSURE
   ──────────────────────────────────────────────────────────────── */
DATA work.raw_exposure;
  LENGTH SUBJID $10 EXTRT $20 EXDOSE 8 EXDOSU $10 EXROUTE $20;
  FORMAT EXSTDTC EXENDTC $10.;

  DO subj = 1 TO 60;
    SUBJID  = CATS('SUBJ', PUT(subj, Z3.));
    EXTRT   = IFC(MOD(subj,2)=1, 'DRUG A', 'PLACEBO');
    EXDOSE  = IFC(MOD(subj,2)=1, 100, 0);
    EXDOSU  = 'mg';
    EXROUTE = 'ORAL';
    EXSTDTC = PUT(MDY(2,1,2026), YYMMDD10.);

    /* Most subjects complete 8 weeks; ~10% discontinue early */
    IF RANUNI(&seed.) < 0.10 THEN
      EXENDTC = PUT(MDY(2,1,2026) + FLOOR(RANUNI(&seed.) * 55), YYMMDD10.);
    ELSE
      EXENDTC = PUT(MDY(2,1,2026) + 56, YYMMDD10.);

    OUTPUT;
  END;
  DROP subj;
RUN;

PROC EXPORT DATA=work.raw_exposure
  OUTFILE="&rawpath./exposure.csv"
  DBMS=CSV REPLACE; RUN;

%PUT NOTE: Raw data generation complete. Files written to &rawpath.;
