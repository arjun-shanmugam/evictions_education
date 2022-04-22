/**********************************************************************/
/*
Evictions & Education | clean_city_level_evictions_data.do

Cleans evictions data from The Eviction Lab at the city level.
*/
/**********************************************************************/

import delimited ${city_level_eviction_data}, clear

drop if parentlocation != "Ohio"  // restrict sample to Ohio

// restrict sample to years during which we have education data
drop if year < 2006 | year >2015

drop parentlocation renteroccupiedhouseholds lowflag imputed subbed

rename geoid place_fips

save ${cleaned_data}/cleaned_city_level_evictions_data.dta, replace

use ${kroeger_la_mattina_data}, clear
keep(place_fips year CANO)


merge 1:1 place_fips year using ${cleaned_data}/cleaned_city_level_evictions_data.dta
// _merge==1: we have CANO data but not education data
drop if _merge == 1
// if city not listed as having nuisance ordinance by Mead et al. (2017), assume it has none
replace CANO = 0 if _merge == 2
drop _merge

save ${cleaned_data}/cleaned_city_level_evictions_and_CANO_data.dta, replace
