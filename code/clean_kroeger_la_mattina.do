/**********************************************************************/
/*
Evictions & Education | clean_kroeger_la_mattina.do

Cleans Kroeger and La Mattina's (2020) city-level nuisance ordiance and
eviction data.
*/
/**********************************************************************/

use ${kroeger_la_mattina_data}, clear

drop city_id  // unique id variable generated by Kroeger and La Mattina

save ${cleaned_data}/cleaned_kroeger_la_mattina.dta, replace
