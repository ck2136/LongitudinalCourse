libname HW3 "C:\Users\Jess\Dropbox\Jessi\Coursework\BIOS6643_Longitudinal\Homework\HW3";

data dog;
set HW3.uni_dogs;
run;

proc print data=dog (obs=10); run;



Title "Dog data without random intercept";
proc mixed data=dog;
class id group time;
model y = group time group*time / solution;
run;

/* p. 167 course book */
Title "Dog data with random intercept";
proc mixed data=dog;
class id group time;
model y = group time group*time / solution;
random intercept / subject=id(group);
ods output =estimates;
run; *Graph of estimates from the mixed model;
symbol1 i=join; axis1 order=(0 to 110 by 10); 
proc sgplot data=estimates; plot estimate*day=group / vaxis=axis1;   run;
  series x=year y=coal;
  series x=year y=naturalgas / y2axis;
run; 
/**I think my SAS isn't working...**/

/* proc glm data=dog;
class id group time;
model y = group	time group*time id(group) / e1;
random id(group) / test ;
run;
*/

/* p. 167 course book */
Title "Dog data with random intercept";
proc mixed data=dog;
class id group time;
model y = group time group*time / solution;
random intercept / subject=id(group) type=CS;
ods output lsmeans=estimates;
run; *Graph of estimates from the mixed model;
