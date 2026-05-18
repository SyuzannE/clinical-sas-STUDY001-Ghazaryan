/* ============================================================
   MACRO: %DERIVE_SEQ
   Purpose : Derives a CDISC-compliant sequence number variable
             (e.g. DMSEQ, VSSEQ, AESEQ) within each subject.
   Usage   : %derive_seq(dsn=vs_work, domain=VS, sortvar=VISITNUM VSTESTCD);
   Params  :
     dsn     – input/output dataset name (modified in place)
     domain  – 2-char SDTM domain code (e.g. VS, AE, EX)
     sortvar – space-separated list of BY variables for ordering
               (USUBJID is always first, do NOT include it here)
   Author  : Syuzanna Ghazaryan | Gurus LLC Internship 2026
   ============================================================ */

%MACRO derive_seq(dsn=, domain=, sortvar=);

  %LET seqvar = %UPCASE(&domain.)SEQ;

  /* Sort by subject then caller-specified variables */
  PROC SORT DATA=&dsn.;
    BY USUBJID &sortvar.;
  RUN;

  DATA &dsn.;
    SET &dsn.;
    BY USUBJID;
    RETAIN &seqvar. 0;
    IF FIRST.USUBJID THEN &seqvar. = 0;
    &seqvar. + 1;
    LABEL &seqvar. = "%UPCASE(&domain.) Sequence Number";
  RUN;

  %PUT NOTE: [derive_seq] &seqvar. derived for dataset &dsn.;

%MEND derive_seq;
