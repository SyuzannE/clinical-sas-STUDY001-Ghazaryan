/*============================================================
  PROGRAM : l_16_2_7_ae.sas
  Output  : Listing 16.2.7 — All Adverse Events
  Study   : STUDY001
  Standard: FDA submission format
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
  Description:
    Produces a complete listing of all treatment-emergent
    adverse events (TRTEMFL=Y), sorted by treatment group,
    subject ID, and AE start date.
    Uses the %ae_listing macro.
============================================================*/

%INCLUDE "&root/setup_libraries.sas";

/* Filter to treatment-emergent AEs only */
DATA work.adae_te;
  SET adam.adae;
  WHERE SAFFL = "Y" AND TRTEMFL = "Y";
  /* Format dates for display */
  ASTDT_C = PUT(ASTDT, DATE9.);
  AENDT_C = PUT(AENDT, DATE9.);
  RENAME ASTDT_C=ASTDTF AENDT_C=AENDTF;
  RENAME AESEV=AESEVN_ORIG;
  LABEL
    ASTDTF = "Start Date"
    AENDTF = "End Date";
RUN;

/* Call the listing macro */
%ae_listing(
  indata  = work.adae_te,
  popfl   = SAFFL,
  outfile = l_16_2_7_ae,
  outpath = &outpath
);

%PUT NOTE: Listing 16.2.7 complete.;
