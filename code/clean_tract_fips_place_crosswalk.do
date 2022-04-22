/**********************************************************************/
/*
Evictions & Education | clean_tract_fips_place_crosswalk.do

Cleans census tract to FIPS place crosswalk.
*/
/**********************************************************************/
#delimit ;
import delimited "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/geocorr2014_2210407490.csv",
                                                   varnames(2) rowrange(2)
                                                   clear;
#delimit cr

// concatenate FIPS place code into one variable
generate string_placecode = string(placecode, "%05.0f")
generate string_statecode = string(statecode)
egen fips_string = concat(string_statecode string_placecode)
generate fips = real(fips_string)
drop string_placecode string_statecode fips_string

// concatenate tract FIPS code into one variable
generate string_countycode = string(countycode)
generate tract_times_100 = tract*100
generate string_tract_code = string(tract_times_100, "%06.0f")
egen string_tract_fips = concat(string_countycode string_tract_code)
destring(string_tract_fips), generate(tract_fips)

#delimit ;
drop   statecode placecode stateabbreviation countyname
     totalpopulation2010 tracttoplacefpallocationfactor countycode
     tract string_countycode tract_times_100 string_tract_code
     string_tract_fips;
#delimit cr

// drop observations corresponding to census tracts that are not in a FIPS place
drop if fips == 3999999

save ${cleaned_data}/cleaned_tract_fips_place_crosswalk.dta, replace

// merge with kroeger and la Mattina

// then, this crosswalk from fips place to tract will only contain fips places that have nuisance ordinances

// reduce this crosswalk to one that uniquely identifies census tracts by nuisance ordinance status so we can do a many to 1 merge

// then, can use this crosswalk to merge education data on census tract with nuisance ordinance data

use ${cleaned_data}/cleaned_kroeger_la_mattina, replace
keep fips year CANO
reshape wide CANO, i(fips) j(year)  // one row for every FIPS place

merge 1:m fips using ${cleaned_data}/cleaned_tract_fips_place_crosswalk.dta
/*
Result                      Number of obs
-----------------------------------------
Not matched                         1,380
    from master                         0  (_merge==1)
    from using                      1,380  (_merge==2)

Matched                             2,439  (_merge==3)
-----------------------------------------
_merge == 1
  0 observations, because every FIPS place in Kroeger and La Mattina appears
  in the crosswalk

_merge == 2
  Many observations, because not all FIPS places appear in Kroeger and La Mattina

*/
drop if _merge != 3
drop _merge


// now, some census tracts cross multiple FIPS places. we need to collapse to census tract levels
bysort tract_fips: generate obs_num_within_tract = _n
egen num_places_spanned_by_tract = max(obs_num_within_tract), by(tract_fips)
tab num_places_spanned_by_tract

// when a tract crosses multiple FIPS places, set its CANO value in year X
// to be the mean of the CANO values in year X of the FIPS places it crosses
# delimit ;
local to_collapse CANO2000 CANO2001 CANO2002 CANO2003 CANO2004 CANO2005 CANO2006
                  CANO2007 CANO2008 CANO2009 CANO2010 CANO2011 CANO2012 CANO2013
                  CANO2014 CANO2015 CANO2016;
#delimit cr
collapse (mean) `to_collapse', by(tract_fips)

foreach var of varlist `to_collapse' {
  tabulate `var'  // every value of each CANO variable should be divible by 4 or 3
}

reshape long CANO, i(tract_fips) j(year)  // convert back to long format
drop if year < 2006
drop if year > 2015

save ${cleaned_data}/tract_level_nuisance_ordinance_data.dta, replace
