/*============================================================
  PROGRAM : qc_compare.sas
  Purpose : Double-programming QC validation script.
            Compares independently-programmed datasets
            against the primary programmer's outputs using
            PROC COMPARE (industry standard method).
  Study   : STUDY001
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
  Usage   :
    1. Second programmer produces qc_sdtm.vs, qc_adam.adsl
       etc. independently in separate library
    2. Run this script to compare results
    3. Zero differences = QC passed
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

/* ── Define QC library (second programmer outputs) ───────── */
/* LIBNAME qcsdtm "&root/data/qc/sdtm"; */
/* LIBNAME qcadam "&root/data/qc/adam";  */

/* ── Macro: run PROC COMPARE and report result ───────────── */
%MACRO qc_compare(base=, comp=, label=);
  %PUT ============================================================;
  %PUT QC CHECK: &label;
  %PUT Base dataset : &base;
  %PUT Compare with : &comp;
  %PUT ============================================================;

  PROC COMPARE BASE=&base COMPARE=&comp
      LISTALL CRITERION=1E-8 NOPRINT
      OUT=work.qc_diff_&label OUTNOEQUAL OUTBASE OUTCOMP;
  RUN;

  %LET nobs = 0;
  PROC SQL NOPRINT;
    SELECT COUNT(*) INTO :nobs FROM work.qc_diff_&label;
  QUIT;

  %IF &nobs = 0 %THEN %DO;
    %PUT NOTE: [QC PASSED] No differences found for &label.;
  %END;
  %ELSE %DO;
    %PUT WARNING: [QC FAILED] &nobs difference(s) found for &label.;
    %PUT WARNING: Review work.qc_diff_&label for details.;
    PROC PRINT DATA=work.qc_diff_&label; RUN;
  %END;
%MEND qc_compare;

/* ── Run QC comparisons ──────────────────────────────────── */
/* Uncomment each line after second programmer delivers QC datasets */

/* %qc_compare(base=sdtm.dm,   comp=qcsdtm.dm,   label=DM);   */
/* %qc_compare(base=sdtm.vs,   comp=qcsdtm.vs,   label=VS);   */
/* %qc_compare(base=sdtm.ae,   comp=qcsdtm.ae,   label=AE);   */
/* %qc_compare(base=sdtm.ex,   comp=qcsdtm.ex,   label=EX);   */
/* %qc_compare(base=adam.adsl, comp=qcadam.adsl, label=ADSL); */
/* %qc_compare(base=adam.adae, comp=qcadam.adae, label=ADAE); */

/* ── Self-validation: check key variable derivations ─────── */

/* 1. ADSL: All SAFFL subjects must have TRTSDT not missing */
PROC SQL;
  SELECT COUNT(*) AS saffl_no_date
  FROM adam.adsl
  WHERE SAFFL = "Y" AND TRTSDT = .;
QUIT;

/* 2. ADSL: ITTFL count should equal DM count (all randomised) */
PROC SQL;
  SELECT
    (SELECT COUNT(*) FROM adam.adsl WHERE ITTFL = "Y") AS ittfl_n,
    (SELECT COUNT(*) FROM sdtm.dm)                     AS dm_n;
QUIT;

/* 3. ADAE: TRTEMFL=Y implies ASTDT >= TRTSDT */
PROC SQL;
  SELECT COUNT(*) AS trtemfl_error
  FROM adam.adae
  WHERE TRTEMFL = "Y" AND ASTDT < TRTSDT;
QUIT;

/* 4. VS: No duplicate VSTESTCD per USUBJID per VISITNUM */
PROC SQL;
  SELECT COUNT(*) AS vs_dups
  FROM (
    SELECT USUBJID, VISITNUM, VSTESTCD, COUNT(*) AS cnt
    FROM sdtm.vs
    GROUP BY USUBJID, VISITNUM, VSTESTCD
    HAVING cnt > 1
  );
QUIT;

%PUT NOTE: QC validation checks complete.;
