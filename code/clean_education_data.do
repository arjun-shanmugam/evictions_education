/**********************************************************************/
/*
Evictions & Education | clean_education_data.do

Cleans Ohio education data.
*/
/**********************************************************************/

// school years in sample
local school_years 0506 0607 0708 0809 0910 1011 1112 1213 1314 1415

// variables to keep in all datasets
local to_keep DistrictIRN DistrictName  Enrollment

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
rename *200506* *6
rename *200607* *7
rename *200708* *8
rename *200809* *9
rename *200910* *10
rename *201011* *11
rename *201112* *12
rename *201213* *13
rename *201314* *14
rename *201415* *15


// reshape each variable
#delimit ;
local stubs math3rdgrade math4thgrade math5thgrade math6thgrade math7thgrade
            math8thgrade read3rdgrade read4thgrade read5thgrade read6thgrade
            read7thgrade read8thgrade enrollment;
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
local to_destring read3rdgrade math3rdgrade read4thgrade math4thgrade
                  read5thgrade math5thgrade read6thgrade math6thgrade
                  read7thgrade math7thgrade read8thgrade math8thgrade
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
