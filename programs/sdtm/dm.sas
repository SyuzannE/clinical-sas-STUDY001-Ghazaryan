/*============================================================
  PROGRAM : dm.sas
  Domain  : DM — Demographics
  Study   : STUDY001
  Standard: SDTM IG v3.4
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
  Description:
    Map raw demographics CSV to SDTM DM domain.
    DM is the first domain produced; it defines USUBJID
    used by all other domains.
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

/* ── Step 1: Import raw demographics ────────────────────── */
PROC IMPORT DATAFILE="&root/data/raw/demographics.csv"
    OUT=work.dm_raw DBMS=CSV REPLACE;
    GETNAMES=YES;
RUN;

/* ── Step 2: Build SDTM DM ──────────────────────────────── */
DATA work.dm_std;
  SET work.dm_raw;

  /* Required SDTM identifiers */
  LENGTH STUDYID $20 DOMAIN $2 USUBJID $30;
  STUDYID = "&studyid";
  DOMAIN  = "DM";
  USUBJID = CATS(STUDYID, "-", STRIP(SUBJID));

  /* Demographics */
  LENGTH BRTHDTC $10 DTHDTC $10;
  /* Age already in source; derive birth date estimate */
  BRTHDTC = PUT(MDY(1,1, YEAR(TODAY()) - AGE), YYMMDD10.);
  DTHDTC  = "";   /* Not applicable in this study */

  /* Standardise SEX per CDISC controlled terminology */
  LENGTH SEXCD $1;
  SEXCD = UPCASE(STRIP(SEX));   /* M / F already correct */

  /* Race — pass through (CDISC CT aligned in source) */
  LENGTH RACECD $60;
  RACECD = STRIP(RACE);

  /* Country ISO 3166 — ARM = Armenia */
  LENGTH COUNTRY $3;
  COUNTRY = "ARM";

  /* Randomisation and study dates */
  LENGTH RFSTDTC $10 RFENDTC $10 RFXSTDTC $10 RFXENDTC $10 DMDTC $10;
  RFSTDTC  = STRIP(RFSTDTC);
  RFENDTC  = STRIP(RFENDTC);
  RFXSTDTC = RFSTDTC;
  RFXENDTC = RFENDTC;
  DMDTC    = RFSTDTC;

  /* Arm and treatment */
  LENGTH ACTARM $40 ACTARMCD $10 ARMCD $10;
  ACTARM   = STRIP(ARM);
  ACTARMCD = IFC(STRIP(ARM)="Drug A", "DRUGA", "PBO");
  ARMCD    = ACTARMCD;

  /* Disposition */
  LENGTH DTHFL $1;
  DTHFL = STRIP(DTHFL);

  /* Subject reference start number */
  SUBJID = STRIP(SUBJID);

  /* Age units */
  LENGTH AGEU $5;
  AGEU = "YEARS";

  /* Ethnic (not in source — set to NOT REPORTED per CDISC CT) */
  LENGTH ETHNIC $30;
  ETHNIC = "NOT REPORTED";

  LABEL
    STUDYID  = "Study Identifier"
    DOMAIN   = "Domain Abbreviation"
    USUBJID  = "Unique Subject Identifier"
    SUBJID   = "Subject Identifier for the Study"
    RFSTDTC  = "Subject Reference Start Date/Time"
    RFENDTC  = "Subject Reference End Date/Time"
    RFXSTDTC = "Date/Time of First Study Treatment"
    RFXENDTC = "Date/Time of Last Study Treatment"
    DTHDTC   = "Date/Time of Death"
    DTHFL    = "Subject Death Flag"
    SITEID   = "Study Site Identifier"
    BRTHDTC  = "Date/Time of Birth"
    AGE      = "Age"
    AGEU     = "Age Units"
    SEXCD    = "Sex"
    RACECD   = "Race"
    ETHNIC   = "Ethnicity"
    ARMCD    = "Planned Arm Code"
    ACTARM   = "Description of Actual Arm"
    ACTARMCD = "Actual Arm Code"
    COUNTRY  = "Country"
    DMDTC    = "Date/Time of Collection";

  /* Keep only SDTM DM variables in correct order */
  KEEP STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC
       RFXSTDTC RFXENDTC DTHDTC DTHFL SITEID BRTHDTC
       AGE AGEU SEXCD RACECD ETHNIC ARMCD ACTARM ACTARMCD
       COUNTRY DMDTC COMPFL;

  RENAME SEXCD=SEX RACECD=RACE;
RUN;

/* ── Step 3: Sort and save ──────────────────────────────── */
PROC SORT DATA=work.dm_std OUT=sdtm.dm;
  BY USUBJID;
RUN;

/* ── Step 4: QC check ───────────────────────────────────── */
PROC CONTENTS DATA=sdtm.dm; RUN;
PROC PRINT DATA=sdtm.dm (OBS=5); RUN;

%PUT NOTE: DM domain complete. Obs: %NOBS(sdtm.dm);
