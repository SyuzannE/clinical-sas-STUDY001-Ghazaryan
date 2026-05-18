/*============================================================
  RUN_ALL.SAS
  Master execution script — runs full pipeline in order.
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

/* ── SDTM ────────────────────────────────────────────────── */
%PUT NOTE: === Running SDTM Programs ===;
%INCLUDE "&root/programs/sdtm/dm.sas";
%INCLUDE "&root/programs/sdtm/ex.sas";
%INCLUDE "&root/programs/sdtm/vs.sas";
%INCLUDE "&root/programs/sdtm/ae.sas";

/* ── ADaM ────────────────────────────────────────────────── */
%PUT NOTE: === Running ADaM Programs ===;
%INCLUDE "&root/programs/adam/adsl.sas";
%INCLUDE "&root/programs/adam/adae.sas";

/* ── TLFs ────────────────────────────────────────────────── */
%PUT NOTE: === Running TLF Programs ===;
%INCLUDE "&root/programs/tlf/t_14_1_1_demog.sas";
%INCLUDE "&root/programs/tlf/l_16_2_7_ae.sas";

%PUT NOTE: === Full pipeline complete for &studyid ===;
