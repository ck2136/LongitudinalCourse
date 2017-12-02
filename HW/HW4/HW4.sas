*******************************
*HW4 Longitudinal Betacarotene*
*******************************

*Step 1: Data Management and Checking;
*Step 1a: Import Data;
proc import datafile="/folders/myshortcuts/FS2016/Longitudinal/HW/HW4/beta carotene.txt"
     out=bc
     dbms=dlm
     replace;
     getnames=yes;
          delimiter=' ';
run;

*Step 1b:Check if the data has right categories (continuous or categorical;
proc contents data=bc;
run;

*Step 1c:id and prepare needs to change to categorical/factor variable;
data bc;
set bc;
char_id = put(id, 7.) ; 
drop id ; 
rename char_id=id ;
char_prepar = put(prepar, 7.) ; 
drop Prepar; 
rename char_prepar=prepar ;
run;
proc contents data=bc;
run;

*Drop the 1st baseline measure, preparer and change name of wk variables to just number;
data bc;
set bc;
drop Base1lvl;
rename Base2lvl = Wk0;
rename Wk6lvl = Wk6;
rename Wk8lvl = Wk8;
rename Wk10lvl = Wk10;
rename Wk12lvl = Wk12;
run;

*Make the hybrid model variables;
data bctemp;
set bc;
Wk6 = Wk6 - Wk0;
Wk8 = Wk8 - Wk0;
Wk10 = Wk10 - Wk0;
Wk12 = Wk12 - Wk0;
run;

data bctemp;
set bctemp;
drop Wk0;
run; 

*Step 1d: wide to long transposing;
proc sort data=bctemp;
by id;
run;

proc sort data=bc;
by id;
run;


proc transpose data=bctemp out=bclong;
   by id;
run;

proc transpose data=bc out=bclong2;
   by id;
run;



*Rename for appropriate long format;
data bclong;
  set bclong(rename=(col1=y));
  Wk=input(substr(_name_, 3), 5.);
  drop _name_;
run;

data bclong2;
  set bclong2(rename=(col1=y));
  Wk=input(substr(_name_, 3), 5.);
  drop _name_;
run;

*merge back the prepar variable;
data bclong;
merge bclong
      bc(keep=id
           Prepar); /** these variables are not transposed **/
by id; 
run;
proc contents data=bclong;
run;

data bclong2;
merge bclong2
      bc(keep=id
           Prepar); /** these variables are not transposed **/
by id; 
run;
proc contents data=bclong;
run;


*Merge baseline measure now to the bclong dataset;
data bcbase;
set bc;
keep id Wk0;
run;


proc sort data=bcbase;
by id;
run;

proc sort data=bclong;
by id;
run;


data bclong;
merge bcbase bclong;
by id;
run;

*Wk is currently in a categorical variable format;

*Step 2: Data visualization
*HW4a: Create a graph for the data.  
You have some flexibility on what type of graph to include;

*baseline as outcome FINAL MODEL;
Proc Glimmix data=bclong2;
class id Prepar wk;
model y = Prepar wk Prepar*wk;
lsmeans Prepar*wk / plots=(meanplot(join sliceby=Prepar)) bylevel; * no CI or SE bar yet;
run;

/*Hybrid Model
Proc Glimmix data=bclong;
class id Prepar wk;
model y = wk0 Prepar wk Prepar*wk;
lsmeans Prepar*wk / plots=(meanplot(join sliceby=Prepar)) bylevel cl; * no CI or SE bar yet;
run;
*/;

*HW4c: analysis methods for efficacy of preparations over time;
proc mixed order=data data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept / subject=id(Prepar); 
contrast 'linear' wk -3 -1 1 3;
contrast 'quadratic' wk  1 -1 -1 1;
contrast 'cubic' wk -1 3 -3 1;
lsmeans prepar*wk;  run;
*Cubic trend for wk and lxl trend significant for prepar*wk significant thus keep just the
lxl term and maybe add the wk wk^2 wk^3 in the model but not specified thus keep simple;


*HW4d: analysis using random slope for time;
*Define new time term for continuous slope;
data bclong2;
set bclong2;
wkcont = wk;
run;


*Using UN for G matrix VC for R;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=UN subject=id(Prepar) v g ; 
repeated /subject=id(Prepar);
lsmeans prepar*wk;  run;

*Using UN G AR(1) R matrix;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=UN subject=id(Prepar); 
repeated /subject=id(Prepar) type=AR(1);
lsmeans prepar*wk;  run;

*Using UN G UN R;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=UN subject=id(Prepar); 
repeated /subject=id(Prepar) type=UN;
lsmeans prepar*wk;  run;

*Using VC for G matrix VC R;
proc mixed data=bclong2;
class id Prepar wk;
model y=  Prepar wk prepar*wk / solution;
random intercept wkcont/ type=VC subject=id(Prepar) v g; 
repeated /subject=id(Prepar);
lsmeans prepar*wk;  run;


*Using VC for G matrix AR R;
proc mixed data=bclong2;
class id Prepar wk;
model y=  Prepar wk prepar*wk / solution;
random intercept wkcont/ type=VC subject=id(Prepar); 
repeated /subject=id(Prepar) type=AR(1);
lsmeans prepar*wk;  run;


*Using VC for G matrix UN R;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=VC subject=id(Prepar); 
repeated /subject=id(Prepar) type=UN;
lsmeans prepar*wk;  run;

*HW4e. No random effect but R with UN;
proc mixed data=bclong2;
class id Prepar wk;
model y=  Prepar wk prepar*wk / solution;
repeated / subject=id(Prepar) type=UN rcorr ; 
lsmeans prepar*wk;  run;


*Final model selection peice based on AIC need to still identify model that would have 
best fit;

*Table 5 AIC Table Output;
*Random intercept no random slope VC R;
proc mixed data=bclong2;
class id Prepar wk;
model y=  Prepar wk prepar*wk / solution;
random intercept / subject=id(Prepar);
repeated / subject=id(Prepar) type=VC;
lsmeans prepar*wk;  run;

*Random intercept no random slope VC R time cont;
proc mixed data=bclong2;
class id Prepar;
model y=  Prepar wk prepar*wk / solution;
random intercept / subject=id(Prepar);
repeated / subject=id(Prepar) type=VC;
run;

*Random intercept no random slope AR1 R;
proc mixed data=bclong2;
class id Prepar wk;
model y=  Prepar wk prepar*wk / solution;
random intercept / subject=id(Prepar);
repeated / subject=id(Prepar) type=AR(1);
lsmeans prepar*wk;  run;

*Random intercept no random slope UN R;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept / subject=id(Prepar);
repeated / subject=id(Prepar) type=UN;
lsmeans prepar*wk;  run;

*UN R no random effect Final Model;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution covb;
repeated / subject=id(Prepar) type=UN ; 
lsmeans prepar*wk;  run;

*VC for R no random effects;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
repeated / subject=id(Prepar) type=VC ; 
lsmeans prepar*wk;  run;

*AR(1) for R no random effects;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
repeated / subject=id(Prepar) type=AR(1) ; 
lsmeans prepar*wk;  run;

*cubic polynomial for time incorporated and time as continuous;
proc mixed data=bclong;
class id Prepar;
model y= Prepar wk wk*wk wk*wk*wk prepar*wk / solution;
repeated / subject=id(Prepar) type=UN ; 
lsmeans prepar*wk;  run;

*Random intercept no random slope UN R;
proc mixed data=bclong;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept / subject=id(Prepar);
repeated / subject=id(Prepar) type=UN;
lsmeans prepar*wk;  run;

*Random intercept no random slope AR1 R;
proc mixed data=bclong;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept / subject=id(Prepar);
repeated / subject=id(Prepar) type=AR(1);
lsmeans prepar*wk;  run;

*Random intercept no random slope VC R;
proc mixed data=bclong;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept / type=UN subject=id(Prepar); 
repeated /subject=id(Prepar) type=VC;
lsmeans prepar*wk;  run;


*RIRS UN G UN R;
proc mixed data=bclong;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=UN subject=id(Prepar); 
repeated /subject=id(Prepar) type=UN;
lsmeans prepar*wk;  run;

*RIRS VC for G matrix VC R;
proc mixed data=bclong;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=VC subject=id(Prepar); 
repeated /subject=id(Prepar) type=VC;
lsmeans prepar*wk;  run;


*RIRS VC for G matrix AR R;
proc mixed data=bclong;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=VC subject=id(Prepar); 
repeated /subject=id(Prepar) type=AR(1);
lsmeans prepar*wk;  run;


*RIRS VC for G matrix UN R;
proc mixed data=bclong;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=VC subject=id(Prepar); 
repeated /subject=id(Prepar) type=UN;
lsmeans prepar*wk;  run;


*Contrast for difference in groups changing over time;
*Using UN for G matrix VC for R Final Model;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=UN subject=id(Prepar); 
repeated /subject=id(Prepar) type=VC;
lsmeans prepar*wk;
contrast 'g4 vs. g2' 	Prepar*wk 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 -1 1 0 0 0,
						Prepar*wk 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 -1 0 1 0 0,
						Prepar*wk 0 0 0 0 0 1 0 0 -1 0 0 0 0 0 0 -1 0 0 1 0,
						Prepar*wk 0 0 0 0 0 1 0 0 0 -1 0 0 0 0 0 -1 0 0 0 1;
contrast 'g3 vs. g2' 	Prepar*wk 0 0 0 0 0 1 -1 0 0 0 -1 1 0 0 0 0 0 0 0 0,
						Prepar*wk 0 0 0 0 0 1 0 -1 0 0 -1 0 1 0 0 0 0 0 0 0,
						Prepar*wk 0 0 0 0 0 1 0 0 -1 0 -1 0 0 1 0 0 0 0 0 0,
						Prepar*wk 0 0 0 0 0 1 0 0 0 -1 -1 0 0 0 1 0 0 0 0 0;
contrast 'g1 vs. g2' 	Prepar*wk -1 1 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0,
						Prepar*wk -1 0 1 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0,
						Prepar*wk -1 0 0 1 0 1 0 0 -1 0 0 0 0 0 0 0 0 0 0 0,
						Prepar*wk -1 0 0 0 1 1 0 0 0 -1 0 0 0 0 0 0 0 0 0 0;
run;

*Contrast for mean difference between groups in at least one time point;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=UN subject=id(Prepar); 
repeated /subject=id(Prepar) type=VC; 
lsmeans prepar*wk; 
contrast 'g4 vs. g2 at least one time' 
Prepar 0 1 0 -1 	Prepar*wk 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 -1 0 0 0 0,
Prepar 0 1 0 -1 	Prepar*wk 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 -1 0 0 0,
Prepar 0 1 0 -1 	Prepar*wk 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 -1 0 0,
Prepar 0 1 0 -1 	Prepar*wk 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 -1 0,
Prepar 0 1 0 -1 	Prepar*wk 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 -1;
contrast 'g3 vs. g2 at least one time' 
Prepar 0 1 -1 0 	Prepar*wk 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0 0 0 0 0,
Prepar 0 1 -1 0  	Prepar*wk 0 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0 0 0 0,
Prepar 0 1 -1 0  	Prepar*wk 0 0 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0 0 0,
Prepar 0 1 -1 0  	Prepar*wk 0 0 0 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0 0,
Prepar 0 1 -1 0  	Prepar*wk 0 0 0 0 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0;
contrast 'g1 vs. g2 at least one time' 
Prepar -1 1 0 0 	Prepar*wk -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0,
Prepar -1 1 0 0 	Prepar*wk 0 -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0,
Prepar -1 1 0 0		Prepar*wk 0 0 -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0,
Prepar -1 1 0 0 	Prepar*wk 0 0 0 -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0,
Prepar -1 1 0 0 	Prepar*wk 0 0 0 0 -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0;
run;

*Contrast in avg g4,3,1 vs. g2;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=UN subject=id(Prepar); 
repeated /subject=id(Prepar) type=VC;
lsmeans prepar*wk; 
contrast 'g4,g3,g1 avg vs. g2' 	Prepar*wk 1 -1 0 0 0 -3 3 0 0 0 1 -1 0 0 0 1 -1 0 0 0,
								Prepar*wk 1 0 -1 0 0 -3 0 3 0 0 1 0 -1 0 0 1 0 -1 0 0,
								Prepar*wk 1 0 0 -1 0 -3 0 0 3 0 1 0 0 -1 0 1 0 0 -1 0,
								Prepar*wk 1 0 0 0 -1 -3 0 0 0 3 1 0 0 0 -1 1 0 0 0 -1;
run;

*Estimates for mean change difference;
proc mixed data=bclong2;
class id Prepar wk;
model y= Prepar wk prepar*wk / solution;
random intercept wkcont/ type=UN subject=id(Prepar); 
repeated /subject=id(Prepar) type=VC;
lsmeans prepar*wk; 
estimate '12wk - baseline g4 vs. g2'	Prepar*wk 0 0 0 0 0 1 0 0 0 -1 0 0 0 0 0 -1 0 0 0 1 / cl;
estimate '12wk - baseline g3 vs. g2'	Prepar*wk 0 0 0 0 0 1 0 0 0 -1 -1 0 0 0 1 0 0 0 0 0 / cl;
estimate '12wk - baseline g1 vs. g2'	Prepar*wk -1 0 0 0 1 1 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 / cl;
run;