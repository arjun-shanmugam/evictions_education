/**********************************************************************/
/*
Evictions & Education | clean_crosswalk.do

Cleans NCES's LEA ID to FIPS place code crosswalk.
*/
/**********************************************************************/

#delimit ;
import excel "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/grf21_lea_place.xlsx", sheet("grf21_lea_place")
                                                                                                        firstrow
                                                                                                        case(lower)
                                                                                                        allstring
                                                                                                        clear;
#delimit cr

drop if substr(place, 1, 2) != "39"  // drop non-Ohio schools

drop landarea waterarea  name_place21 // drop unneeded variables

destring count, replace
rename count num_cities_spanned_by_district  // rename count variable appropriately

bysort place: generate city_group_number = _n
by place: egen num_districts_spanned_by_city = max(city_group_number)
drop city_group_number



save ${cleaned_data}/cleaned_crosswalk.dta, replace
