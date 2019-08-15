libname in 'C:\Users\lfiedlerc\Desktop\Data Analysis';

data in.familychild;
 merge in.nhis2012family  in.nhis2012samplechild (in=inxxchild); 
 by hhx fmx;
 if inxxchild;
 keep RECTYPE SRVY_YR HHX FMX FINT_Y_P FINT_M_P FM_SIZE FM_KIDS FM_ELDR FSRAW SEX AGE_P RACERPI2 HISPAN_I BMI_SC CFLUPNYR CSHFLU12 CSHFLUNM CSHFLUM1 CSHFLUY1 CSHSPFL1 CSHFLUM2 CSHFLUY2 CSHSPFL2 SCHDAYR1; 
run;

proc contents data = in.familychild; run;

*Get all records where flu in the past 12 months was indicated and an answer was given to wether they were vaccinated as well as the method;
data in.cases;
 set in.familychild;
 if CFLUPNYR = 1 then
  if CSHFLU12 = 1 and (CSHSPFL1 = 1 or CSHSPFL1 = 2) then output;
  else if CSHFLU12 = 2 then output;
run;

proc freq data=in.cases;
 where CSHFLU12 = 1;
 table CSHSPFL1;
run;

*Get all records where flu in the past 12 months was NOT indicated and an answer was given to wether they were vaccinated as well as the method;
data in.potential_controls;
 set in.familychild;
 if CFLUPNYR = 2 then
  if CSHFLU12 = 1 and (CSHSPFL1 = 1 or CSHSPFL1 = 2) then output;
  else if CSHFLU12 = 2 then output;
run;

proc freq data=in.potential_controls;
 where CSHFLU12 = 1;
 table CSHSPFL1;
run;

proc format;
 value gender 1 = 'Male'
              2 = 'Female';
 value case_fm 1 = 'Case'
               0 = 'Control';
 value age_group 0-8 = '[0-8]'
                 9-17 = '[9-17]';
 value race 01 = 'White only'
            02 = 'Black/African American only'
            03 - 06 = 'Other';
 value other_children 1 <- high = 'Yes'
                      1 = 'No';
 value elderly 0 = 'No'
               1 - high = 'Yes';
 value num_shots . = 'None'
                 1 = '1'
				 2 = '2'
				 3 - high = '3+';
 value days_missed 0 = 'None'
                   1 - 6 = 'Less than 1 week'
				   7 - 13 = 'Less than 2 weeks'
				   14 - 240 = '2 weeks or more'
				   240 <- 995 = ' '
				   996 = '2 weeks or more'
				   997 - 999 = ' '
                   . = ' ';
run; 

proc freq data=in.cases;
 table sex*age_p/nopercent norow nocol;;
 format sex gender.;
run;

proc sort data=in.potential_controls;
 by sex age_p;
run;

proc surveyselect data=in.potential_controls 
	out = in.controls
	method = srs
	n = (54 58 46 42 44 38 36 36 32 40 36 32 34 40 38 48 44 48 34 52 34 38 30 28 32 44 48 34)
 	seed = 1952;
 strata sex age_p;
run;

proc freq data=in.controls;
 table sex*age_p/nopercent norow nocol;
 format sex gender.;
run;

data in.case_control;
length vaccination $12;
set in.cases (in = flu)
     in.controls;
 if flu = 1 then
  case = 1;
 else
  case = 0;
 if CSHFLU12 = 1 then do;
    if CSHSPFL1 = 1 then vaccination = 'Flu shot';
	if CSHSPFL1 = 2 then vaccination = 'Nasal spray';
 end;
 else vaccination = 'None';
 output;
run;

proc print data=in.case_control(firstobs=1752);
 var CFLUPNYR case;
run;

proc contents data=in.case_control; run;

proc freq data = in.case_control;
 table SCHDAYR1;
run;

proc tabulate data=in.case_control order=formatted missing;
 class case sex age_p RACERPI2 FM_KIDS FM_ELDR SCHDAYR1 CSHFLUNM vaccination;
 table sex age_p (RACERPI2='Race') (FM_KIDS='Lives with other children') (FM_ELDR='Lives with elderly') (SCHDAYR1 = 'School days missed') vaccination,
 (case=' ')*(N COLPCTN);
 format case case_fm. sex gender. age_p age_group. RACERPI2 race. FM_KIDS other_children. FM_ELDR elderly. SCHDAYR1 days_missed.;
run; 

*Crude model;
proc logistic data=in.case_control;
  class vaccination(ref='Flu shot')/param = ref;
  model case = vaccination;
  format case case_fm.;
run;

*Adjusted model;
proc logistic data=in.case_control;
  class vaccination(ref='None')/param = ref;
  model case = vaccination sex age_p RACERPI2 FM_KIDS FM_ELDR SCHDAYR1;
  format case case_fm. sex gender. age_p age_group. RACERPI2 race. FM_KIDS other_children. FM_ELDR elderly. SCHDAYR1 days_missed.;
run;

*create a new data set with the same information but a variable grouping age by stratum;
data in.interaction_model;
set in.case_control;
if age_p < 9 then age_group='[0-8]';
else age_group='[9-17]';
run;

*Adjusted model with interaction;
proc logistic data=in.interaction_model;
  class vaccination(ref='Flu shot') age_group(ref='[0-8]')/param = ref;
  model case = vaccination sex age_group RACERPI2 FM_KIDS FM_ELDR SCHDAYR1 age_group*vaccination;
  format case case_fm. sex gender. RACERPI2 race. FM_KIDS other_children. FM_ELDR elderly. SCHDAYR1 days_missed.;
  oddsratio vaccination / at (age_group='[0-8]');
  oddsratio vaccination / at (age_group='[9-17]');
run;
