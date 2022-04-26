/**********************************************************************/
/*
Evictions & Education | clean_education_data.do

Cleans Ohio education data.
*/
/**********************************************************************/

// school years in sample
local school_years 0506 0607 0708 0809 0910 1011 1112 1213 1314 1415

// variables to keep in all datasets
local to_keep DistrictIRN  Enrollment

// variables to drop in some datasets but not all
local to_drop_specific *Attendance* *EndofCourse* *Absent* *Science* *SocialStudies* *Writ* *PerformanceIndexScore* *OGT* *11th*

// (1) DROP UNNEEDED VARIABLES
// we will also drop observations where DistrictIRN is blank (3)
foreach school_year of local school_years {
  #delimit ;
  // note 1: must manually rename first sheet in 1415_LRC_DISTRICT.xls to "DISTRICT"
  // note 2: must manually rename CityandZipCode to CityandZipcode in 1415_LRC_DISTRICT.xls
  import excel "${raw_data}/`school_year'_LRC_DISTRICT.xls", sheet("DISTRICT")
                                                              firstrow
                                                              clear;
  #delimit cr

  keep `to_keep' *`school_year'*  // variables to keep in all datasets

  // so that enrollment is tracked separately for each school year
  rename Enrollment enrollment20`school_year'

  // variables to drop in specific datasets
  // capture to avoid error when trying to drop a variable not present in dataset
  foreach var of local to_drop_specific {
    capture drop `var'
  }
  drop if DistrictIRN == ""
  save "${cleaned_data}/`school_year'_education_data.dta", replace
}

// (2) MERGE INTO ONE FILE
use "${cleaned_data}/0506_education_data.dta", clear
local school_years_after_0506 0607 0708 0809 0910 1011 1112 1213 1314 1415

foreach school_year of local school_years_after_0506 {

  merge 1:1 DistrictIRN using "${cleaned_data}/`school_year'_education_data.dta", generate(merge_`school_year')

  drop if merge_`school_year' != 3  // 2 obs. unmerged across whole sample
  drop merge_`school_year' // drop merge variable
}

// (3) RESHAPE FROM WIDE TO LONG
// make sure that variable names have consistent case
rename *, lower

// naming format changed in 14'-15'; change so that format matches earlier years
rename reading3rdgrade201415ato read3rdgrade201415atora
rename reading4thgrade201415ato read4thgrade201415atora
rename reading5thgrade201415ato read5thgrade201415atora
rename reading6thgrade201415ato read6thgrade201415atora
rename reading7thgrade201415ato read7thgrade201415atora
rename reading8thgrade201415ato read8thgrade201415atora

// edit variable endings to only include spring term of each school year
rename *rdgrade200506* *_6
rename *thgrade200506* *_6
rename *200506* *_6

rename *rdgrade200607* *_7
rename *thgrade200607* *_7
rename *200607* *_7

rename *rdgrade200708* *_8
rename *thgrade200708* *_8
rename *200708* *_8


rename *rdgrade200809* *_9
rename *thgrade200809* *_9
rename *200809* *_9

rename *rdgrade200910* *_10
rename *thgrade200910* *_10
rename *200910* *_10

rename *rdgrade201011* *_11
rename *thgrade201011* *_11
rename *201011* *_11

rename *rdgrade201112* *_12
rename *thgrade201112* *_12
rename *201112* *_12

rename *rdgrade201213* *_13
rename *thgrade201213* *_13
rename *201213* *_13

rename *rdgrade201314* *_14
rename *thgrade201314* *_14
rename *201314* *_14

rename *rdgrade201415* *_15
rename *thgrade201415* *_15
rename *201415* *_15


// reshape each variable
#delimit ;
local stubs read3_ math3_ read4_ math4_ read5_ math5_ read6_ math6_ read7_ math7_ read8_
            math8_ enrollment_;
#delimit cr
reshape long `stubs', i(districtirn) j(year)



// replace integers representing the year with the actual year (i.e., 6 --> )
forvalues i=6(1)9 {
  replace year = 200`i' if year == `i'
}
forvalues i=10(1)15 {
  replace year = 20`i' if year == `i'
}

// (4) convert numbers stored as strings to numerics
#delimit ;
local to_destring read3 math3 read4 math4
                  read5 math5 read6 math6
                  read7 math7 read8 math8
                  enrollment;
#delimit cr

// some observations contain "NC" instead of number
destring `to_destring', replace force
foreach var of varlist `to_destring'{
  drop if  `var' == .
}

// understand which missing values were dropped
bysort districtirn year: generate year_in_sample = _n
egen max_year_in_sample = max(year_in_sample), by(districtirn)
tab max_year_in_sample
/*
    max_year_in_sample |      Freq.     Percent        Cum.
------------+-----------------------------------
          9 |         72        1.21        1.21
         10 |      5,900       98.79      100.00
------------+-----------------------------------
      Total |      5,972      100.00

      there are 8 schools which are only observed for 9 years
      otherwise, panel balanced
*/
drop max_year_in_sample
drop year_in_sample



save "${cleaned_data}/cleaned_education_data.dta", replace
