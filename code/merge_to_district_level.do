/**********************************************************************/
/*
Evictions & Education | merge_to_district_level.do

Merges all cleaned data to create dataset used for analysis.
*/
/**********************************************************************/


// (1) Merge education data with LEA IDs
// districts identified using Ohio District IRN numbers
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
  These observations are Ledgemont school district and
  Newbury Local School Districts. Both of these school districts are present in
  master but not in using because they have been disbanded. I drop them from the sample.

_merge==2:
  These observations mostly correspond to non-traditional school district
  schools (e.g., charter schools, regional school district, state school
  district). Twelve of them correspond to traditional school districts, but are not
  present in the education data from Ohio Department of Education. I drop all of
  these observations from the sample. See below for a tabulation of school type
  among observations which are present in using but not in master.
*/
drop if _merge == 1
tabulate Type if _merge==2
drop if _merge == 2
drop _merge districtirn Type


// Merge with tract FIPS (2)
// every row is now identified by a LEA ID; match each to one or more FIPS codes
merge 1:m leaid using ${cleaned_data}/cleaned_leaid_tract_crosswalk.dta
/*
Result                      Number of obs
-----------------------------------------
Not matched                             7
    from master                         0  (_merge==1)
    from using                          7  (_merge==2)

Matched                             5,022  (_merge==3)
-----------------------------------------

_merge == 2
  These observations are present in the NCES crosswalk but not in the education
  data because they corresopnd districts that are extremely small (around
  ten students per grade) and are not in the education data. I drop them from
  the sample.
*/
drop if _merge != 3
drop _merge
destring tract_fips, replace  // save FIPS as numeric

// Merge with evictions data (3)
// reshape back to long so that we can merge on FIPS and year with evictions
#delimit ;
local stubs math3rdgrade math4thgrade math5thgrade math6thgrade math7thgrade
            math8thgrade read3rdgrade read4thgrade read5thgrade read6thgrade
            read7thgrade read8thgrade enrollment;
#delimit cr
reshape long `stubs', i(leaid tract_fips) j(year)

// perform merge
merge m:1 tract_fips year using ${cleaned_data}/cleaned_evictions_data.dta
format tract_fips %11.0f
/*
Result                      Number of obs
-----------------------------------------
Not matched                        14,354
    from master                    14,299  (_merge==1)
    from using                         55  (_merge==2)

Matched                            35,921  (_merge==3)
-----------------------------------------
_merge == 1
  These observations fall into two categories. Category one contains
  census tracts which are unmerged for all years in the sample (2006-2015).
  These tracts are unmerged for all years because there is no eviction data on
  those census tracts during the sample period. Category two contains
  census tracts which are unmerged for some years in the sample. These
  observations correspond to tracts for which we have eviction data, but not
  for all years in the sample period.

_merge == 2
  We pre-drop all observations from years for which we lack education data,
  so these observations have to be failing to merge because they correspond to
  FIPS codes which appear in the evictions data but not in the education data.
  This means that not every census tract in Ohio intersects with a school
  district.
*/
preserve
// analysis of unmerged observations from education data
drop if _merge != 1
// within tract_fips year groups, generate ID variable
// if this id variable has max of 10, then tract is observed from 2006-15 and
// none of those tract-year combinations are observed in the eviction data
egen tract_fips_year_id = group(tract_fips year)
bysort tract_fips: egen min_tract_fips_year_id_by_tract = min(tract_fips_year_id)
generate tract_fips_year_id_by_tract = tract_fips_year_id - (min_tract_fips_year_id_by_tract-1)
// this variable gives the number of total years a tract is observed
egen num_years_tract_observed = max(tract_fips_year_id_by_tract), by(tract_fips)
// if id variable has max < 10, then the merge is failing because we are missing
// eviction data for only some years in that census tract
restore

drop if _merge != 3
drop _merge

// Merge with nuisance ordinance data (4)
merge m:1 tract_fips year using ${cleaned_data}/tract_level_nuisance_ordinance_data.dta

/*
Result                      Number of obs
-----------------------------------------
Not matched                        15,590
    from master                    10,513  (_merge==1)
    from using                      5,077  (_merge==2)

Matched                            25,408  (_merge==3)
-----------------------------------------
_merge == 1
  Tract-years which appear in master (education data) but not in using (Kroeger and La Mattina)
  These observations will be filled in with 0's for CANO; they correspond to FIPS places which do not have nuisance ordinances
_merge == 2
  Tract-years which appear in Kroeger and La Mattina but not in education data;
  these are likely tracts that do not overlap with school districts.
*/

drop if _merge == 2
replace CANO = 0 if _merge == 1
drop _merge



// Aggregate to school district-year level (5)
// calculate num. districts spanned by each tract
bysort tract_fips year: egen num_districts_spanned_by_tract = count(tract)
tabulate num_districts_spanned_by_tract
/*
num_distric |
ts_spanned_ |
   by_tract |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |     13,058       36.35       36.35
          2 |     10,876       30.28       66.63
          3 |      5,952       16.57       83.20
          4 |      3,904       10.87       94.07
          5 |      1,375        3.83       97.90
          6 |        510        1.42       99.32
          7 |        182        0.51       99.82
          8 |         64        0.18      100.00
------------+-----------------------------------
      Total |     35,921      100.00
*/



// for each tract, allocate population equally across school districts it spans
generate adjusted_population = population / num_districts_spanned_by_tract
drop population num_districts_spanned_by_tract



// unweighted collapse enrollment, testing variables
#delimit ;
local to_collapse_unweighted math3rdgrade math4thgrade math5thgrade math6thgrade
                             math7thgrade math8thgrade read3rdgrade read4thgrade
                             read5thgrade read6thgrade read7thgrade read8thgrade
                             enrollment evictions evictionfilings;


// weighted collapse demographic, nuisance ordinance eviction variables
local to_collapse_weighted povertyrate pctrenteroccupied mediangrossrent
                           medianhouseholdincome medianpropertyvalue rentburden
                           pctwhite pctafam pcthispanic pctamind pctasian
                           pctnhpi pctmultiple pctother evictionrate
                           evictionfilingrate CANO;
#delimit cr

// temporarily drop all variables which need to be collapsed using weights
preserve

drop `to_collapse_weighted' adjusted_population

collapse (mean) `to_collapse_unweighted', by(leaid DistrictName year)
save ${cleaned_data}/temp.dta, replace

restore

// collapse variables which need to be collapsed using weights
drop `to_collapse_unweighted'
collapse (mean) `to_collapse_weighted' [aweight=adjusted_population], by(leaid DistrictName year)
merge 1:1 leaid DistrictName year using ${cleaned_data}/temp.dta
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             4,622  (_merge==3)
    -----------------------------------------
*/
drop _merge

destring leaid, replace
xtset leaid year

save ${cleaned_data}/final_district_level_dataset.dta, replace
