/*============================================================
  PROGRAM : vs.sas
  Domain  : VS — Vital Signs
  Study   : STUDY001
  Standard: SDTM IG v3.4, Findings Class
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
  Description:
    Map raw vitals CSV (wide format) to SDTM VS domain
    (tall format). One row per subject per visit per test.
    Key challenge: PROC TRANSPOSE + ISO 8601 dates +
    baseline flag (VSBLFL) derivation.
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

PROC IMPORT DATAFILE="&root/data/raw/vitals.csv"
    OUT=work.vs_raw DBMS=CSV REPLACE;
    GETNAMES=YES;
RUN;

/* ── Step 1: Add USUBJID, prep for transpose ────────────── */
DATA work.vs_prep;
  SET work.vs_raw;
  STUDYID = "&studyid";
  USUBJID = CATS(STUDYID, "-", STRIP(SUBJID));
  /* Rename date column to VSDTC (ISO format already) */
  VSDTC   = STRIP(VSDAT);
  DROP SUBJID VSDAT;
RUN;

/* ── Step 2: Transpose wide → tall ─────────────────────── */
PROC TRANSPOSE DATA=work.vs_prep
    OUT=work.vs_tall(RENAME=(_NAME_=VSTESTCD  COL1=VSORRES));
  BY STUDYID USUBJID VISIT VISITNUM VSDTC VSPOS;
  VAR SYSBP DIABP HR WEIGHT HEIGHT;
RUN;

/* ── Step 3: Derive SDTM variables ──────────────────────── */
DATA work.vs_std;
  SET work.vs_tall;

  LENGTH DOMAIN $2 VSTEST $50 VSSTRESU $20 VSORRESU $20;
  DOMAIN = "VS";

  /* Map test codes to labels and units per CDISC CT */
  SELECT (VSTESTCD);
    WHEN ("SYSBP") DO;
      VSTEST   = "Systolic Blood Pressure";
      VSORRESU = "mmHg";
      VSSTRESU = "mmHg";
    END;
    WHEN ("DIABP") DO;
      VSTEST   = "Diastolic Blood Pressure";
      VSORRESU = "mmHg";
      VSSTRESU = "mmHg";
    END;
    WHEN ("HR") DO;
      VSTEST   = "Heart Rate";
      VSORRESU = "beats/min";
      VSSTRESU = "beats/min";
    END;
    WHEN ("WEIGHT") DO;
      VSTEST   = "Weight";
      VSORRESU = "kg";
      VSSTRESU = "kg";
    END;
    WHEN ("HEIGHT") DO;
      VSTEST   = "Height";
      VSORRESU = "cm";
      VSSTRESU = "cm";
    END;
    OTHERWISE DO;
      VSTEST   = VSTESTCD;
      VSORRESU = "";
      VSSTRESU = "";
    END;
  END;

  /* Numeric result */
  VSSTRESN = INPUT(VSORRES, BEST.);

  /* Method */
  LENGTH VSMETHOD $30;
  VSMETHOD = "MANUAL";

  /* CDISC-required category */
  LENGTH VSCAT $20;
  VSCAT = "";

  /* Baseline flag: first visit (VISITNUM=1) */
  LENGTH VSBLFL $1;
  VSBLFL = IFC(VISITNUM = 1, "Y", "");

  /* SDTM requires VSSTRESN character result too */
  LENGTH VSSTRESC $20;
  VSSTRESC = STRIP(PUT(VSSTRESN, BEST.));

  LABEL
    DOMAIN   = "Domain Abbreviation"
    USUBJID  = "Unique Subject Identifier"
    VSTESTCD = "Vital Signs Test Short Name"
    VSTEST   = "Vital Signs Test Name"
    VSORRES  = "Result or Finding in Original Units"
    VSORRESU = "Original Units"
    VSSTRESC = "Character Result/Finding in Std Format"
    VSSTRESN = "Numeric Result/Finding in Standard Units"
    VSSTRESU = "Standard Units"
    VSBLFL   = "Baseline Flag"
    VSPOS    = "Position of Subject During Observation"
    VSDTC    = "Date/Time of Measurements"
    VISIT    = "Visit Name"
    VISITNUM = "Visit Number";

  KEEP STUDYID DOMAIN USUBJID VSTESTCD VSTEST VSCAT
       VSORRES VSORRESU VSSTRESC VSSTRESN VSSTRESU
       VSBLFL VSPOS VSMETHOD VISIT VISITNUM VSDTC;
RUN;

/* ── Step 4: Derive sequence number ─────────────────────── */
%derive_seq(domain=work.vs_std, seqvar=VSSEQ, sortvar=VISITNUM VSTESTCD);

/* ── Step 5: Save ───────────────────────────────────────── */
PROC SORT DATA=work.vs_std OUT=sdtm.vs;
  BY USUBJID VISITNUM VSTESTCD;
RUN;

PROC PRINT DATA=sdtm.vs (OBS=10); RUN;
%PUT NOTE: VS domain complete.;
