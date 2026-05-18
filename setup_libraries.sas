/*============================================================
  SETUP_LIBRARIES.SAS
  Clinical SAS Project — STUDY001
  Programmer : Syuzanna Ghazaryan
  Company    : Gurus LLC, Yerevan, Armenia
  Date       : 2026
  Purpose    : Define all SAS libraries and global macro vars.
               Run this program FIRST before any other program.
============================================================*/

/* ── 1. ROOT PATH — Edit this before running ─────────────── */
%LET root = /path/to/clinical-sas-project;

/* ── 2. Library definitions ──────────────────────────────── */
LIBNAME raw  "&root/data/raw";
LIBNAME sdtm "&root/data/sdtm";
LIBNAME adam "&root/data/adam";

/* ── 3. Global study-level macro variables ───────────────── */
%GLOBAL studyid sponsor protocol phase;
%LET studyid  = STUDY001;
%LET sponsor  = Gurus Academy Simulated Study;
%LET protocol = STUDY001-PROTOCOL-v1.0;
%LET phase    = Phase II;

/* ── 4. Macro library path ───────────────────────────────── */
OPTIONS MAUTOSOURCE SASAUTOS=("&root/programs/macros" SASAUTOS);

/* ── 5. ODS output path ──────────────────────────────────── */
%LET outpath = &root/outputs/tlf;

/* ── 6. Global options ───────────────────────────────────── */
OPTIONS NODATE NONUMBER LINESIZE=200 PAGESIZE=60
        FORMCHAR="|----|+|---+=|-/\<>*";

%PUT NOTE: Libraries and globals initialised for &studyid;
