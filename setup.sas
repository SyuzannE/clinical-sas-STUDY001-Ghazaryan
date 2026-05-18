/* ============================================================
   SETUP.SAS – Master Library and Path Configuration
   Project : Clinical SAS – SDTM / ADaM / TLF Pipeline
   Study   : STUDY001
   Author  : Syuzanna Ghazaryan | Gurus LLC Internship 2026
   ============================================================
   INSTRUCTIONS:
     1. Set &rootpath to the folder where you cloned this repo.
     2. %include this file at the top of every program, OR
        run it once per SAS session before running run_all.sas
   ============================================================ */

/* ── 1. Root path – UPDATE THIS ─────────────────────────────── */
%LET rootpath = /path/to/clinical-sas-project;

/* ── 2. Sub-paths (do not change) ────────────────────────────── */
%LET rawpath   = &rootpath./raw_data;
%LET sdtmpath  = &rootpath./sdtm_datasets;
%LET adampath  = &rootpath./adam_datasets;
%LET macpath   = &rootpath./macros;
%LET tlfpath   = &rootpath./output;
%LET logpath   = &rootpath./logs;
%LET specpath  = &rootpath./specs;

/* ── 3. SAS Libraries ────────────────────────────────────────── */
LIBNAME raw    "&rawpath.";
LIBNAME sdtm   "&sdtmpath.";
LIBNAME adam   "&adampath.";

/* ── 4. ODS style for all TLFs ───────────────────────────────── */
ODS PATH WORK.TEMPLAT(UPDATE) SASUSER.TEMPLAT(READ) SASHELP.TMPLMST(READ);

PROC TEMPLATE;
  DEFINE STYLE styles.clinical;
    PARENT = styles.rtf;
    STYLE fonts /
      'TitleFont'      = ("Times New Roman", 12pt, Bold)
      'TitleFont2'     = ("Times New Roman", 11pt, Bold)
      'StrongFont'     = ("Times New Roman", 10pt, Bold)
      'EmphasisFont'   = ("Times New Roman", 10pt)
      'FixedEmphasisFont' = ("Courier New", 9pt)
      'FixedStrongFont'= ("Courier New", 9pt, Bold)
      'FixedHeadingFont'= ("Courier New", 9pt, Bold)
      'BatchFixedFont' = ("Courier New", 9pt)
      'FixedFont'      = ("Courier New", 9pt)
      'headingEmphasisFont' = ("Times New Roman", 11pt, Bold Italic)
      'headingFont'    = ("Times New Roman", 11pt, Bold)
      'docFont'        = ("Times New Roman", 10pt);
    STYLE body /
      font = ("Times New Roman", 10pt);
    STYLE table /
      frame       = HSIDES
      rules       = GROUPS
      cellpadding = 3pt
      borderspacing = 2pt;
  END;
RUN;

/* ── 5. Load macro library ───────────────────────────────────── */
OPTIONS MAUTOSOURCE SASAUTOS=("&macpath." SASAUTOS);

/* ── 6. Global study metadata ────────────────────────────────── */
%LET studyid  = STUDY001;
%LET sponsor  = Gurus LLC;
%LET protocol = STUDY001-PROTOCOL-v1.0;
%LET cutdate  = 2026-04-30;   /* Clinical data cut-off date */

%PUT NOTE: Setup complete. Root = &rootpath.;
