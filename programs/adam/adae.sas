/*============================================================
  PROGRAM : adae.sas
  Dataset : ADAE — Adverse Events Analysis Dataset
  Study   : STUDY001
  Standard: ADaM IG v1.3
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
  Description:
    Build ADAE from SDTM AE + ADSL.
    Key derivations:
      - TRTEMFL : treatment-emergent flag
        (AE start >= first dose AND AE start <= last dose + 30d)
      - ASTDT / AENDT  : analysis start/end dates (SAS numeric)
      - AESEVN : numeric severity for sorting
      - All ADSL population flags carried across
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

/* ── Step 1: Prepare SDTM AE ────────────────────────────── */
DATA work.ae_prep;
  SET sdtm.ae;
  /* Convert ISO 8601 to SAS dates */
  ASTDT = INPUT(AESTDTC, YYMMDD10.);
  AENDT = INPUT(AEENDTC, YYMMDD10.);
  FORMAT ASTDT AENDT DATE9.;
  KEEP USUBJID AESEQ AETERM AEDECOD AEBODSYS
       AESEV AESEVN AEREL AESER AEOUT AEACN
       AESTDTC AEENDTC ASTDT AENDT;
RUN;

/* ── Step 2: Bring in ADSL variables ────────────────────── */
DATA work.adsl_sub;
  SET adam.adsl;
  KEEP USUBJID TRT01A TRT01AN TRT01P TRT01PN
       TRTSDT TRTEDTM SAFFL ITTFL PPROTFL AGE AGEGR1 SEX RACE;
RUN;

PROC SORT DATA=work.ae_prep  ; BY USUBJID; RUN;
PROC SORT DATA=work.adsl_sub ; BY USUBJID; RUN;

/* ── Step 3: Merge AE + ADSL ────────────────────────────── */
DATA work.adae_raw;
  MERGE work.ae_prep(IN=inae) work.adsl_sub;
  BY USUBJID;
  IF inae;
RUN;

/* ── Step 4: Derive ADaM variables ──────────────────────── */
DATA adam.adae;
  SET work.adae_raw;

  /* Treatment-emergent flag:
     AE starts on or after first dose AND
     on or before last dose + 30-day window */
  LENGTH TRTEMFL $1;
  IF ASTDT NE . AND TRTSDT NE . THEN DO;
    IF ASTDT >= TRTSDT AND
       (AENDT <= TRTEDTM + 30 OR AENDT = .) THEN TRTEMFL = "Y";
    ELSE TRTEMFL = "N";
  END;
  ELSE TRTEMFL = "";

  /* Causality flag — probable or possible */
  LENGTH AREL $1;
  AREL = IFC(AEREL IN ("PROBABLE","POSSIBLE"), "Y", "N");

  /* Severity number (already in AE, carry forward) */
  IF AESEVN = . THEN DO;
    SELECT (AESEV);
      WHEN ("MILD")     AESEVN = 1;
      WHEN ("MODERATE") AESEVN = 2;
      WHEN ("SEVERE")   AESEVN = 3;
      OTHERWISE         AESEVN = .;
    END;
  END;

  /* Serious numeric flag */
  AESERN = (AESER = "Y") * 1;

  /* Analysis sequence number */
  AESEQ_A = AESEQ;   /* Carry SDTM seq */

  /* Study day of AE start relative to first treatment */
  IF ASTDT NE . AND TRTSDT NE . THEN
    ASTDY = ASTDT - TRTSDT + (ASTDT >= TRTSDT);
  ELSE ASTDY = .;

  LABEL
    TRTEMFL = "Treatment Emergent Analysis Flag"
    AREL    = "Analysis Causality Flag"
    AESEVN  = "Severity/Intensity (N)"
    AESERN  = "Serious Event (N)"
    ASTDT   = "Analysis Start Date"
    AENDT   = "Analysis End Date"
    ASTDY   = "Analysis Start Relative Day"
    TRT01A  = "Actual Treatment for Period 01"
    SAFFL   = "Safety Population Flag";
RUN;

PROC SORT DATA=adam.adae;
  BY USUBJID ASTDT AETERM;
RUN;

PROC CONTENTS DATA=adam.adae; RUN;
PROC PRINT DATA=adam.adae (OBS=5); RUN;
%PUT NOTE: ADAE complete.;
