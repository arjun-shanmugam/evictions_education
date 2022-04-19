/**********************************************************************/
/*
Evictions & Education | merge_data.do

Merges all cleaned data to create dataset used for analysis.
*/
/**********************************************************************/


// (1) Merge education data with LEA IDs
// education data currently identified using Ohio District IRN numbers
// match each District IRN number with a LEA ID from NCES
use ${cleaned_data}/cleaned_education_data.dta, replace

// temporarily reshape to wide so that we have 1 row for each district
reshape wide

merge 1:1 districtirn using ${cleaned_data}/cleaned_ohioid_leaid_crosswalk.dta
/*
Result                      Number of obs
-----------------------------------------
Not matched                           451
    from master                        20  (_merge==1)
    from using                        431  (_merge==2)

Matched                             6,060  (_merge==3)
-----------------------------------------

_merge==1:
  These 20 observations are Ledgemont school district and
  Newbury Local School Districts. Both of these school districts are present in
  master but not in using because they have been disbanded. I drop them from the sample.

_merge==2:
  These 431 observations mostly correspond to non-traditional school district
  schools (e.g., charter schools, regional school district, state school
  district). 12 of them correspond to traditional school districts, but are not
  present in the education data from Ohio Department of Education. I drop all of
  these observations from the sample. See below for a tabulation of school type
  among observations which are present in using but not in master.

*/
drop if _merge == 1
tabulate Type if _merge==2
drop if _merge == 2
drop _merge
tab DistrictName


// (2) Merge with city FIPS
// every row is now identified by a LEA ID; match each to one or more FIPS codes
merge 1:m leaid using ${cleaned_data}/cleaned_leaid_fips_crosswalk.dta
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                            83
        from master                        80  (_merge==1)
        from using                          3  (_merge==2)

    Matched                             5,980  (_merge==3)
    -----------------------------------------
    _merge == 1
      There are 8 observations corresponding to 8 districts which are not
      located within a Census-designated place. I drop these from my analysis
    _merge == 2
      Three districts (Kelley's Island, Put-in-Bay, and College Corner) have
      class sizes of around 10 students per grade; these three districts are not
      included in test score dataset. I drop them from my sample.
*/
drop if _merge != 3
drop _merge
destring fips, replace  // so that we can merge with Kroeger and La Mattina

// reshape back to long so that we can collapse to city-year level weighted by enrollment
// #delimit ;
local stubs math3rdgrade math4thgrade math5thgrade math6thgrade math7thgrade ///
            math8thgrade read3rdgrade read4thgrade read5thgrade read6thgrade ///
            read7thgrade read8thgrade enrollment //;
// #delimit cr
reshape long `stubs', i(districtirn fips) j(year)

// // (3) Collapse to city-year level and merge with evictions data
drop DistrictName Type districtirn leaid
#delimit ;
local to_collapse read3rdgrade math3rdgrade read4thgrade math4thgrade
                  read5thgrade math5thgrade read6thgrade math6thgrade
                  read7thgrade math7thgrade read8thgrade math8thgrade;
#delimit cr
collapse (mean) `to_collapse' [aweight=enrollment], by(fips name_place21 year)
// to keep track of where this name variable came from
rename name_place21 nces_cityname
merge 1:1 fips year using ${cleaned_data}/cleaned_kroeger_la_mattina.dta

/*
Matching result from |
               merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
     Master only (1) |     10,153       72.03       72.03
      Using only (2) |      1,486       10.54       82.58
         Matched (3) |      2,456       17.42      100.00
------------------------+-----------------------------------
               Total |     14,095      100.00

Master only (1): Mainly small villages and census designated places that Kroeger
                 and La Mattina do not have data on.
Using only (2): Years for which Kroger and La Mattina have data but during which
                which I do not have education data.

*/
br kroeger_cityname nces_cityname fips year if _merge == 1 & year > 2005 & year < 2016
br kroeger_cityname nces_cityname fips year if _merge == 2 & year > 2005 & year < 2016 // no observations
br kroeger_cityname nces_cityname fips year if _merge == 3 & year > 2005 & year < 2016

// drop unmerged observations
drop if _merge != 3
drop _merge

// in the merged observations, both name variables are identical; drop one
drop nces_cityname
rename kroeger_cityname cityname

// set panelvar and timevar
xtset fips year

save ${cleaned_data}/final_city_level_dataset.dta, replace
