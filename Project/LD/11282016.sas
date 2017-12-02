PROC IMPORT OUT= WORK.B 
            DATAFILE= "E:\others\Lingdiresume\6643\project\project steps\ibs-500.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

proc print data=B(obs=100);
run;

data ibs (keep =PAT_ID rec_spec FROM_DT TO_DT paid PROC_CDE);
set B;
run;

proc print data=ibs(obs=100);
run;
/*check missing data for catergorical variables*/
data ibs01;
set ibs;
where pat_id ne "" and pat_id ne ".";
run;

proc print data=ibs01(obs=100);
run;
/*check missing data for numerical variables*/
proc means data=ibs01 NMISS N; run;

/*there is no missing data in from_dt, to_dt and paid, but there are 62455 missing in proc_cde*/

proc print data=ibs01(obs=100);
run;


* creating variable of counts of procedures to use as predictor ;
data ibs02test;
set ibs01;
where from_dt ne to_dt;
run;
* there are 6702 observations for the start date diffrent from the end date;

data ibs03_err;
set ibs01;
where from_dt > to_dt;
run;
* There are 2 observations from_dt> to_dt*;

data ibs04;
set ibs01;
from_dtnew=.;
to_dtnew=.;
format from_dtnew YYMMDD10.;
format to_dtnew YYMMDD10.;
if from_dt > to_dt then from_dtnew=to_dt;
if from_dt > to_dt then to_dtnew=from_dt;
if from_dt<=to_dt then from_dtnew=from_dt;
if from_dt<=to_dt then to_dtnew=to_dt;
run;
 
* checking for remaining errors;
data ibs04test;
set ibs04;
where from_dtnew>to_dtnew;
run;
/* 0 errors now. Use ibs04*/

proc print data=ibs04(obs=20); run;

libname data 'E:\others\Lingdiresume\6643\project\11282016';
 
data data.ibs04;
set ibs04;
run;

data data.ibs_colon_new;
set data.ibs04;
  if proc_cde = "45330" or
	proc_cde = "45331" or
	proc_cde = "45333" or
	proc_cde = "45334" or
	proc_cde = "45335" or
	proc_cde = "45338" or
	proc_cde = "45346" or
	proc_cde = "45378" or
	proc_cde = "45380" or
	proc_cde = "45381" or
	proc_cde = "45382" or
	proc_cde = "45383" or
	proc_cde = "45384" or
	proc_cde = "45385" or
	proc_cde = "45388" or
	proc_cde = "G0104" or
	proc_cde = "G0105" or
	proc_cde = "G0121" or
	proc_cde = "S0285" or
	proc_cde = "74623" or
	proc_cde = "81528" or
	proc_cde = "82270" or
	proc_cde = "82274" or
	proc_cde = "G0328" then colonprev=1;
	else colonprev=0;
	if proc_cde="."  then  colonprev=0;	
run;

data data.ibs_colon_new1;
set data.ibs_colon_new;
colonpre=1;
run;

proc print data=data.ibs_colon_new1;
run;



proc print data=data.ibs_colon_new (obs=100); run;

/*run models*/
proc mixed data=data.ibs_colon_new;
class pat_id rec_spec;
model paid=colonprev pat_id rec_spec / outpm=out solution;
random intercept /subject=pat_id solution; run;

proc mixed data=data.ibs_colon_new;
class pat_id;
model paid=colonprev pat_id/ outpm=out solution;
random intercept /subject=pat_id solution;
run;


/*code to delete the temp datasets due to sufficient space*/
proc datasets lib=work kill nolist memtype=data;
quit;

symbol c=red i=join value="+" r=4 line=2;
symbol2 c=blue i=join value="-" r=4 line=2;
symbol3 c=red i=spline r=4 width=2;
symbol4 c=blue i=spline r=4 width=2;
axis1 label=("paid") order=(0 to 24 by 4);
axis2 label=("from_dt");

proc gplot data=out;
plot paid*from_dt =pat_id/ vaxis=axis1 haxis=axis2 nolegend;
plot2 pred*time=pat_id / vaxis=axis1 nolegend; run;


proc univariate data=data.ibs_colon_new; var paid; run;
* dataset data.totaldiag02 looks reasonable;




