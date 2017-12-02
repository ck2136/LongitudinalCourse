data ats500;
set ats500;
if event = 0 then eventb =0;
else eventb =1;
t = time;
ts = trt_step;
run;
*Longitudinal Data Analysis Treatment Steps Code;
*Datacleaning and management code should be done here but since we need to make
a graph for initial description, we shall do so;
 
*Setting in library;
libname ats "C:\Users\kimchon\Downloads";

data baseline;
set ats.baseline;
if gender > 0;
run;
 
proc freq data=baseline;
table cci;
run;


*Check missing values;
proc means data=baseline n nmiss;
var _numeric_;
run;

data exposure;
set ats.exposure;
run;
 
data outcomes;
set ats.outcomes;
run;
 
*Need to merge the outcome and exposure to include both;
data temp1;
set exposure;
keep pat_id trt_step start_date;
rename start_date=time;
run;
 
data temp3;
set exposure;
keep pat_id trt_step stop_date;
rename stop_date=time;
run;
 
proc sort data=temp1;
by pat_id;
run;
 
proc sort data=temp3;
by pat_id;
run;
 
data temp2 nodup;
set temp3 temp1;
by pat_id;
run;
 
*removing duplicates which indicate the same treatment step at the same start and stop time;
proc sort data=temp2 NODUP;
by pat_id time;
run;
 
*need to merge exposure now;
 
data temp4;
set outcomes;
keep pat_id event event_date;
rename event_date=time;
run;
 
data temp5;
set temp2 temp4;
by pat_id;
run;
 
proc sort data=temp5;
by pat_id time;
run;

 
*order the time by descending to use retain statement to fill in the missing treatmentstep for event
Important to have >14 gap in trtment as trt_step = 0;
proc sort data=temp5 out=temp6;
  by pat_id time;
run;
 
DATA temp6;
set temp6;
by pat_id time;
retain BackDate Backtrt;
if first.pat_id then do; BackDate=.; Backtrt=' '; end;
if trt_step ne ' ' then do; BackDate=time;Backtrt=trt_step;end;
if (trt_step=' ' and BackDate ne .) then BackDiff=time-BackDate;
RUN;
 
*If backdiff >14 then the trt_step = 0 else it will equal previous value;
*Reference: http://www.mwsug.org/proceedings/2014/PO/MWSUG-2014-PO03.pdf;
 
DATA temp6;
set temp6;
if (trt_step=' ' and Backtrt ne ' ') then /*middle*/
do;
if BackDiff>14  then trt_step=0;
else trt_step=Backtrt;
end;
RUN;
 
 
*Check frequency of the events and treatment steps;
proc freq data=temp5;
table trt_step event ;
run;
 
proc freq data=temp6;
table trt_step event ;
run;
 
*Merge baseline values;
data temp7;
merge baseline temp6;
by pat_id;
run;
 
 
proc format;
value nm . = '.' other = 'X';
value $ch ' ' = '.'other = 'X';
run;
 
proc freq data=temp7;
table pat_id*trt_step*event / list missing nocum;
format _numeric_ nm. _character_ $ch.;
run;
 
*Drop some variables that aren't necessary also assume missing event is no event;
data temp8 ;
set temp7 (drop=BackDate Backtrt Backdiff);
if (trt_step =.) and (event = 0) then delete;
if (event =.) then event = 0;
run;
 
*Create another data set;
*Drop some variables that aren't necessary do not assume missing is no event;
data temp9 ;
set temp7 (drop=BackDate Backtrt Backdiff);
if (trt_step =.) and (event = 0) then delete;
run;

 
/*There are some duplicates in the data so remove them;
proc sort data=temp8 out=temp9 NODUP;
      by pat_id time; Run;
 
 
proc means data = temp8 n nmiss;
  var _numeric_;
run;
 
proc means data=temp8;
var time;
run;
 
proc freq data=temp8;
table trt_step;
run;
***/;
 

*too many sampels so we'll take another of 10000 random sample;
title1 'Pharmetrics Database 55744 patients';
title2 'Simple Random Sampling';

*Select 5000 from baseline;
proc surveyselect data=baseline
   method=srs seed=1234 rep=1 n=5000 out=base5k;
run;


*Merge the baseline values with baseline exposure to create analysis data set 5k;
PROC SQL;
CREATE TABLE ats5k AS
SELECT A.*, B.*
FROM base5k A LEFT JOIN temp8 B
ON A.pat_id = B.pat_id
ORDER BY pat_id;
QUIT;



*Export baseline variables to create Table 1;
proc export data=base5k DBMS=csv
   outfile="/folders/myshortcuts/FS2016/Longitudinal/Project/Data/rs5k.csv";
run;

proc export data=temp8 DBMS=csv
   outfile="/folders/myshortcuts/FS2016/Longitudinal/Project/Data/ats.csv";
run;

*Create the longitudinal data merging baseline values to the randomsample missing included;
PROC SQL;
CREATE TABLE ats5k AS
SELECT A.*, B.*
FROM rs5k A LEFT JOIN temp9 B
ON A.pat_id = B.pat_id
ORDER BY pat_id;
QUIT;

proc sort data=ats5k;
by pat_id time;
run;

proc freq data=ats5k;
table trt_step event / missing;
run;

proc freq data=ats1k;
table trt_step event / missing;
run;


*Create baseline file for Table 1;
proc sort data=ats5k;
by pat_id time;
run;

proc sort data=ats5k nodupkey out=t1 (keep=pat_id trt_step);
by pat_id;
run;

data base5k;
merge base5k t1;
by pat_id;
run;

*Create new variable that changes the order of trt_step so that we can compare odds of trt step to trt_step 0
The new variable trt_stepn's 6 value is the original trt_step 0;
*New variable of event or no event;


data ats5k;
set ats5k;
agen = age + time/365;
month = time/30.4167;
year = time/365;
cost_1k = baseline_cost/1000;
if trt_step = 0 then trt_stepn = 6;
else trt_stepn = trt_step;
if gender > 0;
if event = 0 then eventb =0;
else eventb =1;
run;

*Save to harddrive;
libname ats "/folders/myshortcuts/FS2016/Longitudinal/Project/Data/";

data ats.ats1k;
set ats1k;
run;

data ats.ats5k;
set ats5k;
run;

data ats.ats500;
set ats500;
run;

data ats.ats300;
set ats300;
run;

data ats.base5k;
set base5k;
run;


*Check number of unique subjects in each dataset;
proc freq data=ats500 nlevels;
   tables pat_id;
title 'Number of distinct values for each variable'; 
run; 

proc freq data=ats1k nlevels;
   tables pat_id;
title 'Number of distinct values for each variable'; 
run; 

proc freq data=ats5k nlevels;
   tables gender;
title 'Number of distinct values for each variable'; 
run; 




*Export 1000 random sample file to csv file;
/* Stream a CSV representation of SASHELP.CARS directly to the user's browser. */
proc export data=ats5k
            outfile="C:\Users\kimchon\Downloads\ats5k.csv"
            dbms=csv replace;
run;
 %let _DATAOUT_MIME_TYPE=text/csv;
%let _DATAOUT_NAME=ats5k.csv;

proc export data=base5k
            outfile="C:\Users\kimchon\Downloads\base5k.csv"
            dbms=csv replace;
run;
 %let _DATAOUT_MIME_TYPE=text/csv;
%let _DATAOUT_NAME=base5k.csv;

proc export data=rs5k
            outfile="C:\Users\kimchon\Downloads\base5k.csv"
            dbms=csv replace;
run;
 %let _DATAOUT_MIME_TYPE=text/csv;
%let _DATAOUT_NAME=base5k.csv;

*****************
*load from cloud*
*****************;

libname ats 'C:\Users\kimchon\Downloads';

data ats1k;
set ats.ats1k;
run;

data ats5k;
set ats.ats5k;
run;
data ats500;
set ats.ats500;
run;

data ats300;
set ats.ats300;
run;
