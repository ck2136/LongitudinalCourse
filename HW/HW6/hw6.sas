libname cbd "C:\Users\kimchon\Downloads";

*load data;
data cbd;
set cbd.be_study;
run;

data temp1;
set cbd;
nptenew = round(ntep);
run;


*fit mixed model;
proc mixed data=cbd;
class id gender;
model aado2r = ntep ageep height gender /outp=out solution;
random intercept / subject=id;
run;

*fit using spatial exponent;
proc mixed data=cbd;
class id gender;
model aado2r = ntep ageep height gender /outp=out solution;
random intercept / subject=id;
repeated / subject=id type= sp(exp)(ntep);
run;


*conditional correlation question;
*spatial power with random intercept;
proc mixed data=cbd;
class id gender;
model aado2r = ntep ageep height gender /outp=out solution cl;
random intercept / subject=id;
repeated / subject=id type= sp(pow)(ntep) rcorr r;
run;

*Figure to see what's going on;
proc sgplot data=out;  
series y=pred x=ntep / group=gender;
run;  

*unconditional correlation question;
proc mixed data=cbd;
class id gender;
model aado2r = ntep ageep height gender /outp=out solution;
repeated / subject=id type= sp(pow)(ntep) rcorr r;
run;

*1g: examine histogram of residual and determine if current model acceptable/appropriate;
PROC SGPLOT DATA = out;
 HISTOGRAM resid;
 TITLE "Histogram for Residual of AADO2R data using Spatial Power Structure";
RUN; 

proc stdize data= out out=fig2;
  var resid;
run;

*Normal qqplot;
proc univariate data = fig2 noprint;
  var resid;
  qqplot /href = 0 vref = 0 ;
run;

*Residual by time plot;
 ods listing style=listing;
   
   proc sgplot data=out;
      title 'Residual by time';
      scatter x=ntep y=resid / group=gender;
   run;

      proc sgplot data=out;
      title 'AADO2R by time';
      scatter x=ntep y=aado2r / group=gender;
   run;

   proc sgplot data=out;
   title 'AADO2R by time since exposure';
   series x=ntep y=aado2r / group=id grouplc=gender name='grouping';
   keylegend 'grouping' / type=linecolor;
run;
