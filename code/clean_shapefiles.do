/**********************************************************************/
/*
Evictions & Education | clean_shapefilse.do

Cleans shapefiles.
*/
/**********************************************************************/

cd
shp2dta using ${raw_data}/tl_2010_39_place10, database(${cleaned_data}/city_db) coordinates(${cleaned_data}/ohio_coord) genid(id) replace
use ${cleaned_data}/city_db, clear
egen place_fips = concat(STATEFP10 PLACEFP10)
destring place_fips, replace
#delimit ;
keep if inlist(NAME10, "Bay Village", "Beachwood", "Bedford", "Berea", "Cleveland", "Cleveland Heights") |
        inlist(NAME10, "Mayfield Heights", "Parma", "Shaker Heights", "Strongsville", "East Cleveland", "Euclid") |
        inlist(NAME10,  "Garfield Heights", "Lakewood");
#delimit cr
save ${cleaned_data}/city_db, replace
