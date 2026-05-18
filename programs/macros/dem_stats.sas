/*============================================================
  MACRO: %DEM_STATS
  Purpose : Compute and format descriptive statistics
            (N, Mean, SD, Min, Median, Max) for a numeric
            variable, by treatment group.
  Params  :
    indata  = input ADaM dataset (default: adam.adsl)
    var     = numeric variable to summarise
    varlbl  = label for the row header
    byvar   = by-group variable (default: TRT01A)
    outdata = output summary dataset
  Usage   :
    %dem_stats(var=AGE, varlbl=Age (years), outdata=work.age_sum);
  Programmer : Syuzanna Ghazaryan | Gurus LLC | 2026
============================================================*/

%MACRO dem_stats(indata=adam.adsl, var=, varlbl=, byvar=TRT01A, outdata=);

  %IF %SUPERQ(var)     = %STR() %THEN %DO;
    %PUT ERROR: [dem_stats] var parameter is required.; %RETURN;
  %END;
  %IF %SUPERQ(outdata) = %STR() %THEN %DO;
    %PUT ERROR: [dem_stats] outdata parameter is required.; %RETURN;
  %END;

  PROC MEANS DATA=&indata NOPRINT;
    CLASS &byvar;
    VAR &var;
    OUTPUT OUT=work._stats_
      N=n MEAN=mean STD=std MIN=min MAX=max MEDIAN=median;
  RUN;

  DATA &outdata;
    SET work._stats_;
    WHERE &byvar NE '';
    LENGTH PARAM $50 STAT $30;
    PARAM = "&varlbl";
    STAT  = CATX(' ', 
              PUT(n, 3.),
              '(' || PUT(mean, 6.1) ||
              ' +/- ' || PUT(std, 5.1) || ')');
    LABEL PARAM = "Parameter"
          STAT  = "Statistic";
    KEEP &byvar PARAM STAT n mean std min max median;
  RUN;

  PROC DATASETS LIBRARY=WORK NOLIST; DELETE _stats_; QUIT;

  %PUT NOTE: [dem_stats] Statistics computed for &var -> &outdata;

%MEND dem_stats;
