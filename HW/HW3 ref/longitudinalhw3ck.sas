*Longitudinal HW3;

*Import data from folder;
libname onpc "/folders/myfolders";

*set temporary data;
data dog;
set onpc.uni_dogs;
run;

*Q4b. Graph the mean response by time for each group. one way;
PROC MEANS DATA=dog NWAY NOPRINT;
 CLASS GROUP time;
 VAR y;
 OUTPUT OUT=MEANS MEAN=m_y;
RUN;

proc sgplot data=means;
series x=time y=m_y /
group=group;
run;


*Q4b.	Graph the mean response by time for each group. second way;
Proc Glimmix data=dog;
class id group time;
model y=group time group*time;
lsmeans group*time / plots=(meanplot( join sliceby=group)); * no CI or SE bar yet;
run;

*No random effect;
proc  mixed data=dog; class id group time;
model y = group*time / ddfm=sat solution; 

run;


*Q4.e.i.	Does the difference between the 2 drug groups change over time?
ii. Is there a mean difference between drug groups for at least one time point?
iii. Control vs. average of CH and CL over time?
;
 
proc  mixed data=dog; class id group time;
model y = group*time / noint ddfm=sat solution; random id(group);
contrast 'CH vs. CL, averaged over time' group*time 1 1 1 1 1 -1 -1 -1 -1 -1 0 0 0 0 0;
estimate 'CH vs. CL, time 1' group*time 1 0 0 0 0 -1 0 0 0 0 0 0 0 0 0;
estimate 'CH vs. CL, time 2' group*time 0 1 0 0 0 0 -1 0 0 0 0 0 0 0 0;
estimate 'CH vs. CL, time 3' group*time 0 0 1 0 0 0 0 -1 0 0 0 0 0 0 0;
estimate 'CH vs. CL, time 4' group*time 0 0 0 1 0 0 0 0 -1 0 0 0 0 0 0;
estimate 'CH vs. CL, time 5' group*time 0 0 0 0 1 0 0 0 0 -1 0 0 0 0 0;
contrast 'Control vs. Avg of CH and CL over time' group*time 1 1 1 1 1 1 1 1 1 1 -2 -2 -2 -2 -2;

run;

*Q4f. Get estimates and 95% confidence intervals for each of the following.
i.	The mean change in scores (from BL to 60 minutes after) for the CH group.
ii.	The difference in mean change of scores (BL to 60 min) for the CH group relative to the Control group.
;

proc  mixed data=dog; class id group time;
model y = group*time / noint ddfm=sat solution; random id(group);
estimate 'time 1 vs. time 3 in CH group' group*time 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 / CL;
estimate 'time 1-3 CH vs. time 1-3 CO' group*time 1 0 1 0 0 0 0 0 0 0 -1 0 -1 0 0 / CL;
run;

*Difference in CH vs. CO and CL vs. CO;
proc  mixed data=dog; class id group time;
model y = group*time / noint ddfm=sat solution; random id(group);
contrast 'CH vs. CO, averaged over time' group*time 1 1 1 1 1 0 0 0 0 0 -1 -1 -1 -1 -1;
contrast 'CL vs. CO, averaged over time' group*time 0 0 0 0 0 1 1 1 1 1 -1 -1 -1 -1 -1;
contrast 'average of CH and CL vs. CO, averaged over time' group*time 1 1 1 1 1 1 1 1 1 1 -2 -2 -2 -2 -2;

estimate 'CL vs. CO, time 1' group*time 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0;
estimate 'CL vs. CO, time 2' group*time 0 0 0 0 0 0 1 0 0 0 0 -1 0 0 0;
estimate 'CL vs. CO, time 3' group*time 0 0 0 0 0 0 0 1 0 0 0 0 -1 0 0;
estimate 'CL vs. CO, time 4' group*time 0 0 0 0 0 0 0 0 1 0 0 0 0 -1 0;
estimate 'CL vs. CO, time 5' group*time 0 0 0 0 0 0 0 0 0 1 0 0 0 0 -1;
estimate 'CL vs. CO, time 1' group*time 1 0 0 0 0 0 0 0 0 0 -1 0 0 0 0;
estimate 'CL vs. CO, time 2' group*time 0 1 0 0 0 0 0 0 0 0 0 -1 0 0 0;
estimate 'CL vs. CO, time 3' group*time 0 0 1 0 0 0 0 0 0 0 0 0 -1 0 0;
estimate 'CL vs. CO, time 4' group*time 0 0 0 1 0 0 0 0 0 0 0 0 0 -1 0;
estimate 'CL vs. CO, time 5' group*time 0 0 0 0 1 0 0 0 0 0 0 0 0 0 -1;

run;
