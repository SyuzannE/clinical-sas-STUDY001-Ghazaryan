/*============================================================
  MACRO: %HEADER_FOOTER
  Purpose : Set standardised ODS RTF titles and footnotes
            for all TLF outputs.
  Params  :
    tlfnum  = TLF identifier (e.g. "Table 14.1.1")
    title1  = Primary title text
    title2  = Secondary title text (optional)
    pgmname = Program name for footnote traceability
  Usage   :
    %header_footer(
      tlfnum  = Table 14.1.1,
      title1  = Demographic and Baseline Characteristics,
      title2  = Safety Population,
      pgmname = t_14_1_1_demog.sas
    );
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
============================================================*/

%MACRO header_footer(tlfnum=, title1=, title2=, pgmname=);

  TITLE1  J=L "&studyid"
          J=R "&tlfnum";
  TITLE2  J=C "&title1";
  %IF %SUPERQ(title2) NE %STR() %THEN %DO;
    TITLE3 J=C "&title2";
  %END;

  FOOTNOTE1 J=L "Program: &pgmname"
            J=R "Generated: %SYSFUNC(DATE(), WORDDATE.)";
  FOOTNOTE2 J=L "CONFIDENTIAL — For regulatory submission use only";

%MEND header_footer;
