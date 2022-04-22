/**********************************************************************/
/*
Evictions & Education | merge_to_city_level.do

Merge education data with evictions and CANO data; collapse to city level.
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
Not matched                           433
    from master                         2  (_merge==1)
    from using                        431  (_merge==2)

Matched                               606  (_merge==3)
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


// (2) Merge with city FIPS
// every row is now identified by a LEA ID; match each to one or more FIPS codes
merge 1:m leaid using ${cleaned_data}/cleaned_leaid_fips_crosswalk.dta
/*
  Result                      Number of obs
  -----------------------------------------
  Not matched                            11
      from master                         8  (_merge==1)
      from using                          3  (_merge==2)

  Matched                             1,675  (_merge==3)
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
rename fips place_fips

// reshape back to long so that we can collapse to city-year level weighted by enrollment
#delimit ;
local stubs math3rdgrade math4thgrade math5thgrade math6thgrade math7thgrade
            math8thgrade read3rdgrade read4thgrade read5thgrade read6thgrade
            read7thgrade read8thgrade enrollment;
#delimit cr
reshape long `stubs', i(districtirn place_fips) j(year)


// Collapse to city level and merge with eviction data (3)
bysort leaid year: generate observation_num_within_group = _n
egen num_cities_spanned_by_district = max(observation_num_within_group), by(leaid year)
tab num_cities_spanned_by_district

// equally allocate enrollment across cities spanned by district before collapse
generate adjusted_enrollment = enrollment / num_cities_spanned_by_district
drop enrollment

// collapse
drop DistrictName Type districtirn leaid
#delimit ;
local to_collapse read3rdgrade math3rdgrade read4thgrade math4thgrade
                  read5thgrade math5thgrade read6thgrade math6thgrade
                  read7thgrade math7thgrade read8thgrade math8thgrade;
#delimit cr
collapse (mean) `to_collapse' [aweight=adjusted_enrollment], by(place_fips name_place19 year)

// to keep track of where this name variable came from
rename name_place19 nces_cityname

merge 1:1 place_fips year using ${cleaned_data}/cleaned_city_level_evictions_and_CANO_data.dta
/*
Result                      Number of obs
-----------------------------------------
Not matched                           167
    from master                        60  (_merge==1)
    from using                        107  (_merge==2)

Matched                            12,049  (_merge==3)
-----------------------------------------
_merge==1
  Small CDPs for which we lack evictions data.
_merge==2
  These are cities for which we lack education data; they do not intersect
  with school districts and are larely extremely small.
*/
drop if _merge != 3
drop _merge

// among the merged observations, both name variables are identical; drop one
drop nces_cityname

save ${cleaned_data}/final_city_level_dataset.dta, replace
