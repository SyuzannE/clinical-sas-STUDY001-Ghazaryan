/*============================================================
  MACRO: %AE_LISTING
  Purpose : Generate a standardised adverse events listing
            (Listing 16.2.7 format) as ODS RTF output.
  Params  :
    indata  = input ADAE dataset (default: adam.adae)
    popfl   = population flag variable (default: SAFFL)
    outfile = output RTF filename (no extension)
    outpath = output directory path
  Usage   :
    %ae_listing(outfile=l_16_2_7_ae, outpath=&outpath);
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
============================================================*/

%MACRO ae_listing(indata=adam.adae, popfl=SAFFL,
                  outfile=l_16_2_7_ae, outpath=&outpath);

  %header_footer(
    tlfnum  = Listing 16.2.7,
    title1  = Listing of All Adverse Events,
    title2  = Safety Population,
    pgmname = l_16_2_7_ae.sas
  );

  ODS RTF FILE="&outpath/&outfile..rtf"
      STYLE=Journal STARTPAGE=NO;

  PROC REPORT DATA=&indata(WHERE=(&popfl='Y'))
      NOWD SPLIT='|';
    COLUMN TRT01A USUBJID AETERM AEBODSYS AESEVN AEREL AEOUT AESER ASTDT AENDT;
    DEFINE TRT01A  / ORDER  "Treatment"          WIDTH=12;
    DEFINE USUBJID / ORDER  "Subject ID"         WIDTH=14;
    DEFINE AETERM  / DISPLAY "Preferred Term"    WIDTH=30;
    DEFINE AEBODSYS/ DISPLAY "System Organ Class" WIDTH=30;
    DEFINE AESEVN  / DISPLAY "Severity"          WIDTH=10;
    DEFINE AEREL   / DISPLAY "Relationship"      WIDTH=15;
    DEFINE AEOUT   / DISPLAY "Outcome"           WIDTH=25;
    DEFINE AESER   / DISPLAY "Serious"           WIDTH=8;
    DEFINE ASTDT   / DISPLAY "Start Date"        WIDTH=12;
    DEFINE AENDT   / DISPLAY "End Date"          WIDTH=12;
    BREAK AFTER TRT01A / SKIP;
  RUN;

  ODS RTF CLOSE;
  TITLE; FOOTNOTE;

  %PUT NOTE: [ae_listing] Listing generated -> &outpath/&outfile..rtf;

%MEND ae_listing;
