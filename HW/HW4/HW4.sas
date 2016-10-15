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


*Step 1d: wide to long transposing;
proc sort data=bc;
by id;
run;

proc transpose data=bc out=bclong;
   by id;
run;


*Rename for appropriate long format;
data bclong;
  set bclong(rename=(col1=y));
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
*Wk is currently in a categorical variable format;

*Step 2: Data visualization
*HW4a: Create a graph for the data.  
You have some flexibility on what type of graph to include;

Proc Glimmix data=bclong;
class id Prepar wk;
model y=Prepar wk Prepar*wk;
lsmeans Prepar*wk / plots=(meanplot(join sliceby=Prepar)); * no CI or SE bar yet;
run;

*HW4b: analysis methods for efficacy of preparations over time;
