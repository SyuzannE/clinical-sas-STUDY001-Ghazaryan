/*============================================================
  PROGRAM : ex.sas
  Domain  : EX — Exposure
  Study   : STUDY001
  Standard: SDTM IG v3.4, Interventions Class
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
  Description:
    Map raw exposure CSV to SDTM EX domain.
    EX is produced before VS/AE because ADAE needs
    EXSTDTC/EXENDTC for TRTEMFL derivation.
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

PROC IMPORT DATAFILE="&root/data/raw/exposure.csv"
    OUT=work.ex_raw DBMS=CSV REPLACE;
    GETNAMES=YES;
RUN;

DATA work.ex_std;
  SET work.ex_raw;

  LENGTH STUDYID $20 DOMAIN $2 USUBJID $30;
  STUDYID = "&studyid";
  DOMAIN  = "EX";
  USUBJID = CATS(STUDYID, "-", STRIP(SUBJID));

  /* Treatment name and dose */
  LENGTH EXTRT $40 EXDOSU $10 EXROUTE $20 EXDOSFRM $20 EXDOSFRQ $10;
  EXTRT    = STRIP(EXTRT);
  EXDOSU   = STRIP(EXDOSU);
  EXROUTE  = STRIP(EXROUTE);
  EXDOSFRM = "TABLET";
  EXDOSFRQ = STRIP(EXDOSFRQ);

  /* ISO 8601 date/time variables */
  LENGTH EXSTDTC $10 EXENDTC $10;
  EXSTDTC = STRIP(EXSTDAT);
  EXENDTC = STRIP(EXENDAT);

  /* Visit info — single epoch in this study */
  LENGTH EPOCH $20 VISIT $30;
  EPOCH = "TREATMENT";
  VISIT = "Overall Treatment";
  VISITNUM = 1;

  LABEL
    STUDYID  = "Study Identifier"
    DOMAIN   = "Domain Abbreviation"
    USUBJID  = "Unique Subject Identifier"
    EXTRT    = "Name of Treatment"
    EXDOSE   = "Dose per Administration"
    EXDOSU   = "Dose Units"
    EXDOSFRM = "Dose Form"
    EXDOSFRQ = "Dosing Frequency per Interval"
    EXROUTE  = "Route of Administration"
    EXSTDTC  = "Start Date/Time of Treatment"
    EXENDTC  = "End Date/Time of Treatment"
    VISIT    = "Visit Name"
    VISITNUM = "Visit Number"
    EPOCH    = "Epoch";

  KEEP STUDYID DOMAIN USUBJID EXTRT EXDOSE EXDOSU
       EXDOSFRM EXDOSFRQ EXROUTE EXSTDTC EXENDTC
       VISIT VISITNUM EPOCH;
RUN;

/* Derive EXSEQ */
%derive_seq(domain=work.ex_std, seqvar=EXSEQ, sortvar=EXSTDTC);

PROC SORT DATA=work.ex_std OUT=sdtm.ex;
  BY USUBJID;
RUN;

PROC PRINT DATA=sdtm.ex (OBS=5); RUN;
%PUT NOTE: EX domain complete.;
