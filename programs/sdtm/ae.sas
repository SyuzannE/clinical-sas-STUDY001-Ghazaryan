/*============================================================
  PROGRAM : ae.sas
  Domain  : AE — Adverse Events
  Study   : STUDY001
  Standard: SDTM IG v3.4, Events Class
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
  Description:
    Map raw adverse events CSV to SDTM AE domain.
    Includes derivation of AESEV numeric sort var,
    ISO 8601 dates, and MedDRA-aligned coding fields.
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

PROC IMPORT DATAFILE="&root/data/raw/adverse_events.csv"
    OUT=work.ae_raw DBMS=CSV REPLACE;
    GETNAMES=YES;
RUN;

DATA work.ae_std;
  SET work.ae_raw;

  LENGTH STUDYID $20 DOMAIN $2 USUBJID $30;
  STUDYID = "&studyid";
  DOMAIN  = "AE";
  USUBJID = CATS(STUDYID, "-", STRIP(SUBJID));

  /* Preferred term (verbatim mapped → AETERM already clean) */
  LENGTH AETERM $100 AEDECOD $100 AEBODSYS $80 AEHLT $80;
  AETERM   = STRIP(AETERM);
  /* In a real study, AEDECOD comes from MedDRA coding;
     here we use verbatim as proxy */
  AEDECOD  = AETERM;
  AEBODSYS = STRIP(AEBODSYS);
  AEHLT    = "";   /* High-Level Term — requires MedDRA */

  /* Severity: standardise to CDISC controlled terminology */
  LENGTH AESEV $10;
  AESEV = UPCASE(STRIP(AESEV));

  /* Numeric severity for sorting (not a standard SDTM var
     but useful for QC; stored as derived variable) */
  SELECT (AESEV);
    WHEN ("MILD")     AESEVN = 1;
    WHEN ("MODERATE") AESEVN = 2;
    WHEN ("SEVERE")   AESEVN = 3;
    OTHERWISE         AESEVN = .;
  END;

  /* Relationship to treatment */
  LENGTH AEREL $20;
  AEREL = UPCASE(STRIP(AEREL));

  /* Serious adverse event flag */
  LENGTH AESER $1;
  AESER = UPCASE(STRIP(AESER));

  /* Outcome */
  LENGTH AEOUT $40;
  AEOUT = STRIP(AEOUT);

  /* ISO 8601 dates */
  LENGTH AESTDTC $10 AEENDTC $10;
  AESTDTC = STRIP(AESTDAT);
  AEENDTC = STRIP(AEENDAT);

  /* Action taken (not in source — default) */
  LENGTH AEACN $40;
  AEACN = "DOSE NOT CHANGED";

  /* AECONTRT: concomitant treatment for AE */
  LENGTH AECONTRT $3;
  AECONTRT = "N";

  LABEL
    DOMAIN   = "Domain Abbreviation"
    USUBJID  = "Unique Subject Identifier"
    AETERM   = "Reported Term for the Adverse Event"
    AEDECOD  = "Dictionary-Derived Term"
    AEBODSYS = "Body System or Organ Class"
    AESEV    = "Severity/Intensity"
    AESEVN   = "Severity (numeric, 1=Mild 2=Mod 3=Sev)"
    AEREL    = "Causality"
    AESER    = "Serious Event"
    AEOUT    = "Outcome of Adverse Event"
    AEACN    = "Action Taken with Study Treatment"
    AECONTRT = "Concomitant or Additional Trtmnt Given"
    AESTDTC  = "Start Date/Time of Adverse Event"
    AEENDTC  = "End Date/Time of Adverse Event";

  DROP SUBJID AESTDAT AEENDAT;
RUN;

/* ── Derive AESEQ ────────────────────────────────────────── */
%derive_seq(domain=work.ae_std, seqvar=AESEQ, sortvar=AESTDTC AETERM);

PROC SORT DATA=work.ae_std OUT=sdtm.ae;
  BY USUBJID AESTDTC;
RUN;

PROC PRINT DATA=sdtm.ae (OBS=5); RUN;
%PUT NOTE: AE domain complete.;
