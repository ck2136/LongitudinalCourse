
****************
*Model Building*
****************;

*load library for university edition;
libname ats "/folders/myshortcuts/FS2016/Longitudinal/Project/Data/";
data ats1k;
set ats.ats1k;
run;

data ats300;
set ats.ats300;
run;


*load library from library edition;
libname ats "C:\Users\kimchon\Downloads/";
data ats1k;
set ats.ats1k;
run;

data ats5k;
set ats.ats5k;
run;



*****************************************************
*Hypothesis 1 Factors Associated with Treatment Step*
*****************************************************;

*Model with no variables;
proc glimmix data=ats1k method = quad;
class pat_id region trt_step gender (ref=first) Insurance (ref=first);
model trt_step(desc) = / cl dist=multinomial link=cumlogit solution oddsratio ;
run;
*AIC: 74595.63;


*Model with no variables Random Intercept;
proc glimmix data=ats1k method = quad;
class pat_id region trt_step gender (ref=first) Insurance (ref=first);
model trt_step(desc) = / cl dist=multinomial link=cumlogit solution oddsratio ;
random int / subject=pat_id;
COVTEST  "NEED RANDOM INTERCEPT?" 0; 
run;
*AIC: 72873.33 p-value <.0001 ;


*Model with fixed and random slope for time by subject with Random Intercept;
proc glimmix data=ats1k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first);
model trt_step(desc) = year / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
COVTEST  "NEED RANDOM Slope?" . 0 0; 
run;
*AIC: 72847.61 optimization failed during setup because function value cannot be imrpoved ;

*Add in apriori variables of interest;
proc glimmix data=ats1k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year age gender region cci insurance cost_1k / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 72846.26; 

/*

*Add in potential interaction year*gender;
proc glimmix data=ats1k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first);
model trt_step(desc) = year gender year*gender region cci insurance/ cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 72846.95;

*Add in potential interaction;
proc glimmix data=ats1k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first);
model trt_step(desc) = year gender year*gender year*region region cci insurance/ cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 72850.29;


*/


*Polynomial trend for time;
proc glimmix data=ats1k method = quad;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year age gender region cci insurance cost_1k / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 72745.40 delta=0.8;

proc glimmix data=ats1k method = quad;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year age gender region cci insurance cost_1k / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 72733.55 delta=12;


proc glimmix data=ats1k method = quad;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year age gender region cci insurance cost_1k / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 72679.21 delta=50;

proc glimmix data=ats1k method = quad;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year year*year*year*year*year age gender region cci insurance cost_1k / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 72644.05 delta=35;

*sextic;
proc glimmix data=ats1k method = quad;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year year*year*year*year*year year*year*year*year*year*year 
age gender region cci insurance cost_1k / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 72614.25 delta=30;

/*
*septic AIC goes up;
proc glimmix data=ats1k method = quad;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year year*year*year*year*year year*year*year*year*year*year year*year*year*year*year*year*year
age gender region cci insurance cost_1k / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 72626.31 delta=30;
*/
/*
*G structure VC or UN;
proc glimmix data=ats1k method = quad;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year year*year*year*year*year year*year*year*year*year*year 
age gender region cci insurance cost_1k / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id type=UN;
run;
*AIC: 72614.01;
*/

*Now build up to bigger database;
proc glimmix data=ats5k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year year*year*year*year*year year*year*year*year*year*year 
age gender region cci insurance / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;
*AIC: 372562.9;

*Trying 5th, 4th, and 3rd polynomial for sensitivity;
proc glimmix data=ats5k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year year*year*year*year*year  
age gender region cci insurance / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;

proc glimmix data=ats5k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year   
age gender region cci insurance / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;


proc glimmix data=ats5k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year   
age gender region cci insurance / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;

proc glimmix data=ats5k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year   
age gender region cci insurance / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;

proc glimmix data=ats5k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year  
age gender region cci insurance / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id;
run;

*Treatment step as nominal outcome;
proc glimmix data=ats5k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year year*year*year*year*year year*year*year*year*year*year 
age gender region cci insurance / cl dist=multinomial link=glogit solution oddsratio ;
random int year / subject=pat_id group=trt_step;
run;
*insufficient memory note;

/*
*Using UN structure for G structure;
proc glimmix data=ats5k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year year*year*year*year*year year*year*year*year*year*year 
age gender region cci insurance cost_1k / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id type=UN;
run;
*AIC: 372573.2 AIC actualy increases ; 
*/


*Final Output for Hypothesis 1;
/*
ods pdf file="C:\Users\kimchon\Downloads\H1csats1k.pdf";
proc glimmix data=ats1k method=quad(qpoints=50) NOPROFILE;
class pat_id region trt_step gender (ref=first) Insurance (ref=first);
model trt_step(DESC) = year year*year age gender region cci insurance  cost_1k/ cl dist=multinomial solution oddsratio;
random int year/ subject=pat_id;
ods select FitStatistics CovParms ParameterEstimates Tests3 ;
      ods trace on;
      ods show;
run;
ods pdf close;
ods trace on;

ods pdf file="C:\Users\kimchon\Downloads\H1csats300.pdf";
proc glimmix data=ats300 method=quad(qpoints=50) NOPROFILE;
class pat_id region trt_step gender (ref=first) Insurance (ref=first);
model trt_step(DESC) = year year*year age gender region cci insurance  / chisq cl dist=multinomial solution oddsratio;
random int year/ subject=pat_id;
ods select FitStatistics CovParms ParameterEstimates Tests3 ;
      ods trace on;
      ods show;
run;
ods pdf close;
ods trace on;
*/
ods pdf file="C:\Users\kimchon\Downloads\H15k.pdf";
proc glimmix data=ats5k method = laplace;
class pat_id region trt_step gender (ref=first) Insurance (ref=first) ;
model trt_step(desc) = year year*year year*year*year year*year*year*year year*year*year*year*year year*year*year*year*year*year 
age gender region cci insurance / cl dist=multinomial link=cumlogit solution oddsratio ;
random int year / subject=pat_id g;
	output out=glimmixout 	pred( blup ilink)=PredProb
							pred(noblup ilink)=PredProb_PA;
run;
ods pdf close;
ods trace on;

****************************************************************
*Hypothesis 2 Factors Associated with Asthma Exacerbaiton Event*
****************************************************************;

*h2model1: outcome as binomial;
*binary outcome event(yes/no) ;

*model with random intercept;
proc glimmix data=ats1k ;
class pat_id region trt_step(ref=first) gender (ref=first) Insurance (ref=first);
model eventb(descending)= year trt_step trt_step*year age gender region cci insurance/ cl dist=binary link=logit solution oddsratio;
random intercept year/ subject=pat_id type=vc;
run;
*Does not converge with RSPL;



*h2model 1;
proc glimmix data=ats1k method=quad;
class pat_id region trt_step(ref=first) gender (ref=first) Insurance (ref=first);
model eventb(descending)= year trt_step age gender region cci insurance/ cl dist=binary link=logit solution oddsratio;
random intercept year/ subject=pat_id type=vc;
run;
*AIC: 15460.83;

*h2model 1 with interaction;
proc glimmix data=ats1k method=quad;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first);
model eventb(event=first)= year trt_step year*trt_step age gender region cci insurance cost_1k/ cl dist=binary link=logit solution oddsratio;
random intercept year/ subject=pat_id type=vc;
ods select FitStatistics Tests3 CovParms;
      ods trace on;
      ods show;
run;
*AIC: 15420.15 delta=9 and interaction significant;


*h2model2: polynomial trend;
proc glimmix data=ats1k method=quad;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first);
model eventb(event=first)= year year*year trt_step year*trt_step age gender region cci insurance cost_1k/ cl dist=binary link=logit solution oddsratio;
random intercept year/ subject=pat_id type=vc;
ods select FitStatistics Tests3 CovParms;
      ods trace on;
      ods show;
run;
*AIC: 15421.13 delta=+1 AIC increases?;

*cubic;
ods pdf file="C:\Users\kimchon\Downloads\H2a5k.pdf";
proc glimmix data=ats5k method=laplace;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first);
model eventb(descending)= year year*year year*year*year trt_step year*trt_step age gender region cci insurance / cl dist=binary link=logit solution oddsratio;
random intercept year / subject=pat_id type=vc;
output out=glimmixout 	pred( blup ilink)=PredProb
						pred(noblup ilink)=PredProb_PA
						lcl( blup ilink)=lclpp
						lcl(noblup ilink)=lclpp_pa
						ucl( blup ilink)=uclpp
						ucl(noblup ilink)=uclpp_pa
;
run;
ods pdf close;
*AIC: 15416.65 delta=4;

*Predicted probability plot Marginal model looks good;
title 'Predicted Probability of Event using Marginal Model';
proc sgplot data=glimmixout;
	scatter x=year y=PredProb_PA / group=trt_step;
run;

title 'Predicted Probability of Event using Conditional Model';
proc sgplot data=glimmixout;
	scatter x=year y=PredProb / group=trt_step;
run;


/*
*The conditional distribution using random effect sucks;
proc sgplot data=glimmixout;
	scatter x=year y=PredProb / group=trt_step;
run;
*/
/*
*quartic;
proc glimmix data=ats1k method=quad;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first);
model eventb(event=first)= year year*year year*year*year year*year*year*year trt_step year*trt_step age gender region cci insurance cost_1k/ cl dist=binomial link=logit solution oddsratio;
random intercept / subject=pat_id type=vc;
ods select FitStatistics Tests3 CovParms;
      ods trace on;
      ods show;
run;
*AIC: 15440.57 increases!?;

*quintic;
proc glimmix data=ats1k method=quad;
class pat_id region trt_stepn gender (ref=first) Insurance (ref=first);
model eventb(event=first)= time time*time time*time*time time*time*time*time time*time*time*time*time trt_step time*trt_step age gender region cci insurance / cl dist=binomial link=logit solution oddsratio;
random intercept / subject=pat_id;
ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 15698.60;

*sextic;
proc glimmix data=ats1k ;
class pat_id region trt_stepn gender (ref=first) Insurance (ref=first);
model eventb(event=first)= time time*time time*time*time time*time*time*time time*time*time*time*time time*time*time*time*time*time trt_step time*trt_step age gender region cci insurance / cl dist=binomial link=logit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 16378.51;

*septic;
proc glimmix data=ats1k ;
class pat_id region trt_stepn gender (ref=first) Insurance (ref=first);
model eventb(event=first)= time time*time time*time*time time*time*time*time time*time*time*time*time time*time*time*time*time*time time*time*time*time*time*time*time 
		trt_step time*trt_step age gender region cci insurance  / cl dist=binomial link=logit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 16374.00 Final model for inference;

*octic;
proc glimmix data=ats1k ;
class pat_id region trt_stepn gender (ref=first) Insurance (ref=first);
model eventb(event=first)= time time*time time*time*time time*time*time*time time*time*time*time*time time*time*time*time*time*time time*time*time*time*time*time*time
		time*time*time*time*time*time*time*time time*trt_step
		trt_step age gender region cci insurance  / cl dist=binomial link=logit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 16370.19;

*nontic;
proc glimmix data=ats1k ;
class pat_id region trt_stepn gender (ref=first) Insurance (ref=first);
model eventb(event=first)= time time*time time*time*time time*time*time*time time*time*time*time*time time*time*time*time*time*time time*time*time*time*time*time*time
		time*time*time*time*time*time*time*time time*time*time*time*time*time*time*time*time time*trt_step
		trt_step age gender region cci insurance  / cl dist=binomial link=logit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 16367.55 some survey variables DF become infinite;


*septic without interaction;
proc glimmix data=ats1k ;
class pat_id region trt_stepn gender (ref=first) Insurance (ref=first);
model eventb(event=first)= time time*time time*time*time time*time*time*time time*time*time*time*time time*time*time*time*time*time time*time*time*time*time*time*time 
		trt_step age gender region cci insurance baseline_cost / cl dist=binomial link=logit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 16374.00 Final model for inference;

proc glimmix data=ats1k ;
class pat_id region trt_stepn gender (ref=first) Insurance (ref=first);
model eventb(event=first)= time time*time time*time*time time*time*time*time time*time*time*time*time time*time*time*time*time*time time*time*time*time*time*time*time 
		trt_step age gender region cci insurance baseline_cost / cl dist=binomial link=logit solution oddsratio;
run;
*/;


*H2b: Using Outcome as multinomial nominal;

proc glimmix data=ats1k method=laplace;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) event(ref=first);
model event(event=first)= year year*year trt_step year*trt_step age gender cci / cl dist=multinomial link=glogit solution oddsratio;
random intercept / subject=pat_id type=vc group=event;
ods select FitStatistics Tests3 CovParms;
      ods trace on;
      ods show;
run;
*AIC= 21722.28;

*Cubic;
ods pdf file="C:\Users\kimchon\Downloads\H2mn5k.pdf";
proc glimmix data=ats5k method=laplace;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) event(ref=first);
model event(event=first)= year year*year year*year*year trt_step year*trt_step age gender cci / cl dist=multinomial link=glogit solution oddsratio;
random intercept / subject=pat_id type=vc group=event;
output out=glimouth2	pred( blup ilink)=PredProb
						pred(noblup ilink)=PredProb_PA;
run;
ods pdf close;
*AIC= 21709.06;


*Predicted probability plot Marginal model looks good;
title 'Predicted Probability of Event(Nominal) using Marginal Model';
proc sgplot data=glimouth2;
	loess x=year y=PredProb_PA / group=_LEVEL_;
run;

/*
*Quartic;
proc glimmix data=ats1k method=laplace;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) event(ref=first);
model event(event=first)= year year*year year*year*year year*year*year*year trt_step year*trt_step age gender cci cost_1k/ cl dist=multinomial link=glogit solution oddsratio;
random intercept / subject=pat_id type=vc group=event;
ods select FitStatistics Tests3 CovParms;
      ods trace on;
      ods show;
run;
*AIC= 21714.34 delta=inc by 5;

*2b: outcome as multinomial nominal takes too long;
%macro
ats(outcome, cov1, cov2, cov3, cov4, cov5, cov6,cov7,cov8, link, dist, subj, Gtype)
;
proc glimmix data=ats1k method=laplace;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) &outcome;
model &outcome (event=first) = &cov1 &cov2 &cov3 &cov4 &cov5 &cov6 &cov7 &cov8 / cl dist=&dist link=&link solution oddsratio;
random intercept / subject=&subj type=&Gtype group=&outcome;
run;

%mend ats;
*check time polynomial possibility;
%ats(eventn, age, gender, cci, time, time*time, time*time*time, no_dx ,trt_step ,glogit,multinomial,pat_id,vc)

;*Takes 2 minutes proceed with caution;
*Model doesn't converge with random intercept;

*H2bmodel1 Model with all covariates;
proc glimmix data=ats1k;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) eventn;
model eventn(event=first) = time trt_step age gender region cci insurance baseline_cost / cl dist=multinomial link=glogit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 22458.84;

*H2bmodel2: Polynomial Trend;
proc glimmix data=ats1k;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) eventn;
model eventn(event=first) = time time*time trt_step age gender region cci insurance baseline_cost / cl dist=multinomial link=glogit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 22431.54 delta=17;

*Cubic;
proc glimmix data=ats1k;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) eventn;
model eventn(event=first) = time time*time time*time*time trt_step age gender region cci insurance baseline_cost / cl dist=multinomial link=glogit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 22412.50 delta=19;

*quartic;
proc glimmix data=ats1k;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) eventn;
model eventn(event=first) = time time*time time*time*time time*time*time*time trt_step age gender region cci insurance baseline_cost / cl dist=multinomial link=glogit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 22401.68 delta=11;

*quintic;
proc glimmix data=ats1k;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) eventn;
model eventn(event=first) = time time*time time*time*time time*time*time*time time*time*time*time*time trt_step age gender region cci insurance baseline_cost / cl dist=multinomial link=glogit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;

*AIC: 22375.27 delta=25;


*model with interaction between time and trt_step;

proc glimmix data=ats1k;
class pat_id region trt_step (ref=first) gender (ref=first) Insurance (ref=first) eventn;
model eventn(event=first) = time time*trt_step time*time time*time*time time*time*time*time time*time*time*time*time trt_step age gender region cci insurance baseline_cost / cl dist=multinomial link=glogit solution oddsratio;
      ods select FitStatistics Tests3;
      ods trace on;
      ods show;
run;
*AIC: 22384.22;

*next step 
1. Predictive Probability plot for H1 and H2(binomial);
2. Final wrap up;
