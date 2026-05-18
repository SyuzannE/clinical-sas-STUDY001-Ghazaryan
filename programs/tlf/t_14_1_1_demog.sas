/*============================================================
  PROGRAM : t_14_1_1_demog.sas
  Output  : Table 14.1.1 — Demographic and Baseline
            Characteristics (Safety Population)
  Study   : STUDY001
  Standard: FDA submission format
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
  Description:
    Produces a standard demographic summary table by
    treatment group using ADSL, Safety Population (SAFFL=Y).
    Continuous vars: Age, Weight, Height.
    Categorical vars: Sex, Race, Age Group.
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

/* ── Step 1: Subset to Safety Population ────────────────── */
DATA work.adsl_safe;
  SET adam.adsl;
  WHERE SAFFL = "Y";
RUN;

/* ── Step 2: Treatment column counts (N=) ───────────────── */
PROC FREQ DATA=work.adsl_safe NOPRINT;
  TABLES TRT01A / OUT=work.trt_n;
RUN;

/* ── Step 3: Continuous variables — Age ─────────────────── */
%dem_stats(indata=work.adsl_safe, var=AGE,    varlbl=Age (years),   outdata=work.s_age);

/* ── Step 4: Categorical variable — Sex ─────────────────── */
PROC FREQ DATA=work.adsl_safe NOPRINT;
  TABLES TRT01A * SEX / OUT=work.freq_sex(KEEP=TRT01A SEX COUNT PERCENT);
RUN;

/* ── Step 5: Categorical variable — Race ────────────────── */
PROC FREQ DATA=work.adsl_safe NOPRINT;
  TABLES TRT01A * RACE / OUT=work.freq_race(KEEP=TRT01A RACE COUNT PERCENT);
RUN;

/* ── Step 6: Age group ───────────────────────────────────── */
PROC FREQ DATA=work.adsl_safe NOPRINT;
  TABLES TRT01A * AGEGR1 / OUT=work.freq_agegr(KEEP=TRT01A AGEGR1 COUNT PERCENT);
RUN;

/* ── Step 7: Produce RTF table ───────────────────────────── */
%header_footer(
  tlfnum  = Table 14.1.1,
  title1  = Demographic and Baseline Characteristics,
  title2  = Safety Population (SAFFL=Y),
  pgmname = t_14_1_1_demog.sas
);

ODS RTF FILE="&outpath/t_14_1_1_demog.rtf"
    STYLE=Journal STARTPAGE=NO;

/* N by treatment header row */
PROC REPORT DATA=work.trt_n NOWD SPLIT="|";
  COLUMN TRT01A COUNT;
  DEFINE TRT01A / DISPLAY "Treatment Group" WIDTH=30;
  DEFINE COUNT  / DISPLAY "N"               WIDTH=6;
RUN;

/* Continuous: age */
PROC REPORT DATA=work.s_age NOWD SPLIT="|";
  COLUMN PARAM TRT01A STAT;
  DEFINE PARAM  / GROUP  "Parameter"         WIDTH=30;
  DEFINE TRT01A / ACROSS "Treatment"         WIDTH=20;
  DEFINE STAT   / DISPLAY "N (Mean ± SD)"   WIDTH=20;
RUN;

/* Categorical: sex */
PROC REPORT DATA=work.freq_sex NOWD SPLIT="|";
  COLUMN TRT01A SEX COUNT PERCENT;
  DEFINE TRT01A / GROUP   "Treatment"       WIDTH=20;
  DEFINE SEX    / DISPLAY "Sex"             WIDTH=10;
  DEFINE COUNT  / DISPLAY "n"               WIDTH=6;
  DEFINE PERCENT/ DISPLAY "%"               WIDTH=8 FORMAT=6.1;
RUN;

/* Categorical: race */
PROC REPORT DATA=work.freq_race NOWD SPLIT="|";
  COLUMN TRT01A RACE COUNT PERCENT;
  DEFINE TRT01A / GROUP   "Treatment"       WIDTH=20;
  DEFINE RACE   / DISPLAY "Race"            WIDTH=40;
  DEFINE COUNT  / DISPLAY "n"               WIDTH=6;
  DEFINE PERCENT/ DISPLAY "%"               WIDTH=8 FORMAT=6.1;
RUN;

ODS RTF CLOSE;
TITLE; FOOTNOTE;

%PUT NOTE: Table 14.1.1 complete -> &outpath/t_14_1_1_demog.rtf;
