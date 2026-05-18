/*============================================================
  MACRO: %DERIVE_SEQ
  Purpose : Derive sequence number (--SEQ) within USUBJID
            for any SDTM domain.
  Params  :
    domain  = work dataset name (modified in place)
    seqvar  = name of sequence variable to create (e.g. VSSEQ)
    sortvar = space-separated list of sort variables after USUBJID
  Usage   :
    %derive_seq(domain=work.vs_std, seqvar=VSSEQ, sortvar=VISITNUM VSTESTCD);
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
============================================================*/

%MACRO derive_seq(domain=, seqvar=, sortvar=);

  %IF %SUPERQ(domain)  = %STR() %THEN %DO;
    %PUT ERROR: [derive_seq] domain parameter is required.; %RETURN;
  %END;
  %IF %SUPERQ(seqvar)  = %STR() %THEN %DO;
    %PUT ERROR: [derive_seq] seqvar parameter is required.;  %RETURN;
  %END;
  %IF %SUPERQ(sortvar) = %STR() %THEN %DO;
    %PUT ERROR: [derive_seq] sortvar parameter is required.; %RETURN;
  %END;

  PROC SORT DATA=&domain;
    BY USUBJID &sortvar;
  RUN;

  DATA &domain;
    SET &domain;
    BY USUBJID;
    RETAIN &seqvar 0;
    IF FIRST.USUBJID THEN &seqvar = 0;
    &seqvar + 1;
    LABEL &seqvar = "Sequence Number";
  RUN;

  %PUT NOTE: [derive_seq] &seqvar derived successfully for &domain;

%MEND derive_seq;
