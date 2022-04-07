/**********************************************************************/
/*
Evictions & Education | clean_education_data.do

Cleans Ohio education data.
*/
/**********************************************************************/

// school years in sample
local school_years 0506 0607 0708 0809 0910 1011 1112 1213 1314 1415

// variables to keep in all datasets
local to_keep DistrictIRN DistrictName County CityandZipcode Enrollment

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

// separate cityandzipcode variables
split cityandzipcode, parse("  ")  // first split on double space
drop cityandzipcode  // drop original variable
rename cityandzipcode1 city_state // contains "City, State"
rename cityandzipcode2 zipcode  // contains zip code
split city_state, parse(", ")  // split "City, Ohio" to "City" and "Ohio"
rename city_state1 city  // gives name of city
drop city_state2  // always equal to "Ohio"
drop city_state 

//
save "${cleaned_data}/cleaned_education_data.dta", replace
