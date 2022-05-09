/**********************************************************************/
/*
Evictions & Education | clean_educational_attainment_data.do

Cleans data on educational attainment.

*/
/**********************************************************************/

import delimited ${educational_attainment_data_2010}, varnames(2) clear

keep id totalestimatebachelorsdegree
rename totalestimatebachelorsdegree num_with_bachelors
replace num_with_bachelors = "0" if num_with_bachelors == "-"
destring num_with_bachelors, replace
generate place_fips = substr(id, 10, 7)
destring place_fips, replace
drop id
expand 5

bysort place_fips: generate year = _n + 2005

save ${cleaned_data}/cleaned_educational_attainment_data.dta, replace


import delimited ${educational_attainment_data_2015}, varname(2) clear
keep id v25 v11
generate num_with_bachelors = v25 + v11
generate place_fips = substr(id, 10, 7)
destring place_fips, replace
drop id
expand 5
bysort place_fips: generate year = _n + 2010

append using ${cleaned_data}/cleaned_educational_attainment_data.dta

drop v25 v11
save ${cleaned_data}/cleaned_educational_attainment_data.dta, replace
