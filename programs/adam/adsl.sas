/*============================================================
  PROGRAM : adsl.sas
  Dataset : ADSL — Subject-Level Analysis Dataset
  Study   : STUDY001
  Standard: ADaM IG v1.3
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
  Description:
    Build ADSL from SDTM DM + EX.
    Derives:
      - Treatment variables (TRT01A, TRT01P, TRTSDT, TRTEDTM)
      - Population flags (SAFFL, ITTFL, PPROTFL)
      - Age group (AGEGR1, AGEGR1N)
      - Treatment duration (TRTDURD)
      - Completion flag (COMPFL)
    ADSL is the backbone dataset; all other ADaM datasets
    merge to it for population flags.
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

/* ── Step 1: Load SDTM DM ───────────────────────────────── */
PROC SORT DATA=sdtm.dm  OUT=work.dm_s;  BY USUBJID; RUN;
PROC SORT DATA=sdtm.ex  OUT=work.ex_s;  BY USUBJID; RUN;

/* ── Step 2: Summarise EX — first/last dose per subject ─── */
PROC MEANS DATA=work.ex_s NOPRINT;
  BY USUBJID;
  VAR EXDOSE;
  OUTPUT OUT=work.ex_sum(DROP=_TYPE_ _FREQ_) N=EXDOSEN;
RUN;

DATA work.ex_dates;
  SET work.ex_s;
  BY USUBJID;
  /* Convert ISO 8601 strings to SAS dates */
  TRTSDT_  = INPUT(EXSTDTC, YYMMDD10.);
  TRTEDTM_ = INPUT(EXENDTC, YYMMDD10.);
  FORMAT TRTSDT_ TRTEDTM_ DATE9.;
  KEEP USUBJID EXTRT EXDOSE TRTSDT_ TRTEDTM_;
RUN;

PROC SORT DATA=work.ex_dates NODUPKEY; BY USUBJID; RUN;

/* ── Step 3: Merge DM + EX ──────────────────────────────── */
DATA work.adsl_raw;
  MERGE work.dm_s(IN=indm) work.ex_dates work.ex_sum;
  BY USUBJID;
  IF indm;
RUN;

/* ── Step 4: Derive ADaM variables ──────────────────────── */
DATA adam.adsl;
  SET work.adsl_raw;

  /* ── Treatment variables ── */
  LENGTH TRT01A $40 TRT01P $40 TRT01AN 8 TRT01PN 8;
  TRT01A = STRIP(EXTRT);
  TRT01P = TRT01A;   /* Single period: planned = actual */
  TRT01AN = IFC(TRT01A = "Drug A", 1, 2) * 1;
  TRT01PN = TRT01AN;

  TRTSDT  = TRTSDT_;
  TRTEDTM = TRTEDTM_;
  FORMAT TRTSDT TRTEDTM DATE9.;

  /* ── Age group ── */
  LENGTH AGEGR1 $10;
  IF      AGE <  18        THEN DO; AGEGR1 = "<18";    AGEGR1N = 1; END;
  ELSE IF 18 <= AGE <= 64  THEN DO; AGEGR1 = "18-64";  AGEGR1N = 2; END;
  ELSE IF AGE >= 65        THEN DO; AGEGR1 = ">=65";   AGEGR1N = 3; END;

  /* ── Population flags ── */
  /* Safety: received at least 1 dose */
  LENGTH SAFFL $1;
  SAFFL  = IFC(TRTSDT NE ., "Y", "N");

  /* ITT: all randomised subjects */
  LENGTH ITTFL $1;
  /* RFSTDTC present => randomised */
  ITTFL  = IFC(RFSTDTC NE "", "Y", "N");

  /* Per-Protocol: completed study (COMPFL=Y) */
  LENGTH PPROTFL $1;
  PPROTFL = IFC(STRIP(COMPFL) = "Y", "Y", "N");

  /* ── Treatment duration (days) ── */
  IF TRTSDT NE . AND TRTEDTM NE . THEN
    TRTDURD = TRTEDTM - TRTSDT + 1;
  ELSE TRTDURD = .;

  /* ── Study completion ── */
  LENGTH EOSSTT $20;
  EOSSTT = IFC(STRIP(COMPFL)="Y", "COMPLETED", "DISCONTINUED");

  LABEL
    TRT01A  = "Actual Treatment for Period 01"
    TRT01P  = "Planned Treatment for Period 01"
    TRT01AN = "Actual Treatment for Period 01 (N)"
    TRT01PN = "Planned Treatment for Period 01 (N)"
    TRTSDT  = "Date of First Exposure to Treatment"
    TRTEDTM = "Date of Last Exposure to Treatment"
    AGEGR1  = "Pooled Age Group 1"
    AGEGR1N = "Pooled Age Group 1 (N)"
    SAFFL   = "Safety Population Flag"
    ITTFL   = "Intent-to-Treat Population Flag"
    PPROTFL = "Per-Protocol Population Flag"
    TRTDURD = "Total Treatment Duration (Days)"
    EOSSTT  = "End of Study Status";

  DROP TRTSDT_ TRTEDTM_ EXTRT EXDOSEN;
RUN;

PROC SORT DATA=adam.adsl; BY USUBJID; RUN;

PROC CONTENTS DATA=adam.adsl; RUN;
PROC PRINT DATA=adam.adsl (OBS=5); RUN;
%PUT NOTE: ADSL complete.;
