*Import Data from CSV;
proc import datafile="C:\Users\kimchon\Downloads\campck1.csv" out=camp1 dbms=dlm replace;
   delimiter=",";
   getnames=yes;
run;

proc import datafile="C:\Users\kimchon\Downloads\campck2.csv" out=camp2 dbms=dlm replace;
   delimiter=",";
   getnames=yes;
run;

*Objective: Visualize Random sample of 10 subjects for during/after treatment period to identify trend of PREFEV, FEV/FVC, and Bronchial Responsiveness;


*Get only 10 sample from the treatment time period;
proc surveyselect data = camp1 method = SRS rep = 1 
  sampsize = 10 seed = 12345 out = camprs10;
  id _all_;
run;

*Get only 10 sample after the treatment time period;
proc surveyselect data = camp2 method = SRS rep = 1 
  sampsize = 10 seed = 12345 out = camprs10at;
  id _all_;
run;

data camprs10;
set camprs10;
keep id;
run;

data camprs10at;
set camprs10at;
keep id;
run;

*merge back original longitudinal data for each people in the random sample;
PROC SQL;
CREATE TABLE camprs10n AS
SELECT A.*, B.*
FROM camprs10 A LEFT JOIN camp1 B
ON A.id = B.id
ORDER BY id;
QUIT;

PROC SQL;
CREATE TABLE camprs10nat AS
SELECT A.*, B.*
FROM camprs10at A LEFT JOIN camp2 B
ON A.id = B.id
ORDER BY id;
QUIT;

proc sort data=camprs10n;
by id visitc;
run;

proc sort data=camprs10nat;
by id visitc;
run;



************************************************************************************
*Graphical Visualization: Random Sample Spaghetti Plots and Average Values per Time*
************************************************************************************

*Spaghetti first;

*All subjects during treatment period spaghetti plot... not informative;
proc sgplot data=camp1;
   title 'PREFEV by Treatment Group over the treatment period';
   series x=visitc y=PREFEV / group=id grouplc=TG name='grouping';
   keylegend 'grouping' / type=linecolor;
run;

*All subjects after treatment period spaghetti plot... not informative;
proc sgplot data=camp2;
   title 'PREFEV by Treatment Group over the treatment period';
   series x=visitc y=PREFEV / group=id grouplc=TG name='grouping';
   keylegend 'grouping' / type=linecolor;
run;

*Random Sample of 10 Spaghetti Plot to see if there is random intercept or slope during treatment period;
*Outcome: PREFEV;
proc sgplot data=camprs10n;
   title 'PREFEV by Treatment Group over the treatment period';
   series x=visitc y=PREFEV / group=id grouplc=TG name='grouping';
   keylegend 'grouping' / type=linecolor;
run;
*Outcome: FEV/FVCpp PREFF;
proc sgplot data=camprs10n;
   title 'FEV/FVCpp (%) by Treatment Group over the treatment period';
   series x=visitc y=PREFF / group=id grouplc=TG name='grouping';
   keylegend 'grouping' / type=linecolor;
run;
*Outcome: bronchial responsiveness brm;
proc sgplot data=camprs10n;
   title 'Bronchial Responsiveness to Bronchodilator by Treatment Group over the treatment period';
   series x=visitc y=brm / group=id grouplc=TG name='grouping';
   keylegend 'grouping' / type=linecolor;
run;



*Random Sample of 10 Spaghetti Plot to see if there is random intercept or slope after treatment period;
*Outcome: PREFEV;
proc sgplot data=camprs10nat;
   title 'PREFEV by Treatment Group after the treatment period';
   series x=visitc y=PREFEV / group=id grouplc=TG name='grouping';
   keylegend 'grouping' / type=linecolor;
run;
*Outcome: FEV/FVCpp PREFF;
proc sgplot data=camprs10nat;
   title 'FEV/FVCpp (%) by Treatment Group over the treatment period';
   series x=visitc y=PREFF / group=id grouplc=TG name='grouping';
   keylegend 'grouping' / type=linecolor;
run;
*Outcome: bronchial responsiveness brm;
proc sgplot data=camprs10nat;
   title 'Bronchial Responsiveness to Bronchodilator by Treatment Group over the treatment period';
   series x=visitc y=brm / group=id grouplc=TG name='grouping';
   keylegend 'grouping' / type=linecolor;
run;



*average values;


*Average PREFEV by treatment group by visit month during treatment period;
*Outcome = PREFEV;
proc glm data = camp1 plots(maxpoints=100000);
 class TG;
 model PREFEV = visitc visitc*TG /solution xpx i ss3;
run; quit;
*Outcome = PREFF;
proc glm data = camp1 plots(maxpoints=100000);
 class TG;
 model PREFF = visitc visitc*TG /solution xpx i ss3;
run; quit;
*Outcome = brm;
proc glm data = camp1 plots(maxpoints=100000);
 class TG;
 model brm = visitc visitc*TG /solution xpx i ss3;
run; quit;

*Average PREFEV by treatment group by visit month after treatment period;
proc glm data = camp2 plots(maxpoints=100000);
 class TG;
 model PREFEV = visitc visitc*TG /solution xpx i ss3;
run; quit;
*Outcome = PREFF;
proc glm data = camp2 plots(maxpoints=100000);
 class TG;
 model PREFF = visitc visitc*TG /solution xpx i ss3;
run; quit;
*Outcome = brm;
proc glm data = camp2 plots(maxpoints=100000);
 class TG;
 model brm = visitc visitc*TG /solution xpx i ss3;
run; quit;



*Baseline characteristics for table 1 created in R;
