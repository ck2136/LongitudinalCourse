*import from sas university edition;
PROC IMPORT DBMS=csv OUT=Cereal2
DATAFILE="/folders/myshortcuts/FS2016/Longitudinal/Gary/Cereal2.csv";
GETNAMES=YES;
RUN;

*Data Managment;

*Appendix Create indicator variables for NLmixed;
DATA creal1 ;
  SET creal1 ;
 
  IF cond2= 0 THEN cond2_0 = 1; 
    ELSE cond2_0 = 0;
  IF cond2 = 1 THEN cond2_1 = 1; 
    ELSE cond2_1 = 0;
  IF sex = 0 THEN sex_0 = 1; 
    ELSE sex_0 = 0;
  IF sex = 1 THEN sex_1 = 1; 
    ELSE sex_1 = 0;

RUN;

/*create new variable cond2 and keep the interested variables*/

data creal1(keep=cond cond2 C1 FamIDNO FamMem Sex Age1 Ht1 Wt1);

set Cereal2; cond2=1-cond; if FamMem=3;

run;

proc print data= creal1(obs=20); run;


/*1a: Poisson*/
PROC GENMOD data=creal1;
CLASS cond2(ref=last) sex;
MODEL C1 = cond2 sex Wt1 / dist = poisson link=log;
RUN;



/*1b: Overdispersion QL*/
PROC GENMOD data=creal1;
CLASS cond2(ref=last) sex;
MODEL C1 = cond2 sex Wt1 / dist = poisson link=log dscale;
RUN;


/*1C: overdispersion by adding a random normal error to the linear
predictor in the Poisson GzLM*/
proc nlmixed data=creal1;
title 'REGULAR NLMIXED';
eta = b0 + b1*cond2_0 + b2*cond2_1 + b3*sex_0 + b4*sex_1 + b5*wt1 + eps; mu = exp(eta);
model c1 ~ poisson(mu);
random eps ~ normal(0, sig*sig) subject=famidno;
estimate 'b1-b2' b1-b2;
estimate 'b3-b4' b3-b4;
run;

proc nlmixed data=creal1;
title 'NLMINXED+error&#39';
Model C1 ~ Poisson( exp( b0 + b1*cond2_0 + b2*cond2_1 + b3*sex_0 + b4*sex_1 + b5*wt1 + eps));
random eps ~ normal( 0, sig*sig ) subject=famidno; run;


*HW1D: Negative Binomial;
proc nlmixed data=creal1;
mu = exp( b0 +b1*cond2_0 + b2*cond2_1 + b3*sex_0 + b4*sex_1 + b5*wt1 );
LL = C1*log(k*mu) - (C1+1/k)*log(1+k*mu) + log(gamma(C1+1/k) /
(gamma(1/k)*gamma(C1+1)));
model C1 ~ general( LL );
estimate 'b1-b2' b1-b2;
estimate 'b3-b4' b3-b4;
run;

*HW1D: Negative Binomial;
proc genmod data=creal1;
class cond2 sex;
model C1 = cond2 sex Wt1 / dist = negbin link = log dscale;
run;

 