/**********************************************************************/
/*
Evictions & Education | clean_evictions_data.do

Cleans census tract-year level eviction data from The Eviction Lab.
*/
/**********************************************************************/

import delimited ${eviction_data}, clear

// drop years for which we do not have education data
drop if year < 2006 | year > 2015

rename geoid tract_fips

format tract_fips %11.0f

#delimit ;
drop imputed subbed lowflag name parentlocation
     renteroccupiedhouseholds;
#delimit cr

save ${cleaned_data}/cleaned_evictions_data.dta, replace
