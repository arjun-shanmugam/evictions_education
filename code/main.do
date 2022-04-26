/**********************************************************************/
/*  Evictions & Education ~ main do-file  */
/**********************************************************************/

// set your own path and define globals appropriately
if c(username) == "arjunshanmugam" {

  // RAW DATA
	global raw_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data"
	global kroeger_la_mattina_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/kroeger_la_mattina"
  global leaid_fips_place_crosswalk "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/grf19_lea_place.xlsx"
	global leaid_tract_crosswalk "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/grf19_lea_tract.xlsx"
	global ohioid_leaid_crosswalk "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/ncesdata_7C561E22.xlsx"
	global tract_fips_place_crosswalk "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/geocorr2014_2210407490.csv"
	global eviction_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/OH_tracts.csv"
	global city_level_eviction_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/cities.csv"

  // CLEANED DATA
  global cleaned_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/cleaned_data"

  // OUTPUT
	global output_tables "/Users/arjunshanmugam/Documents/GitHub/evictions_education/output/tables"
	global output_graphs "/Users/arjunshanmugam/Documents/GitHub/evictions_education/output/graphs"

  // CODE
  global code "/Users/arjunshanmugam/Documents/GitHub/evictions_education/code"

}


local district_level 1
local city_level_final 0

if `city_level_final' {


	do ${code}/clean_leaid_fips_crosswalk.do

 	do ${code}/clean_ohioid_leaid_crosswalk.do

 	do ${code}/clean_education_data.do

	do ${code}/clean_city_level_evictions_CANO_data.do

	do ${code}/merge_to_city_level.do

	// do ${code}/city_level_analysis.do

}


if `district_level' {
	do ${code}/clean_kroeger_la_mattina.do

	do ${code}/clean_education_data.do

	do ${code}/clean_ohioid_leaid_crosswalk.do

	do ${code}/clean_leaid_tract_crosswalk.do

	do ${code}/clean_evictions_data.do

	do ${code}/clean_tract_fips_place_crosswalk.do

	// TODO: merge data and allocate evictions to school districts
	do ${code}/merge_to_district_level.do

	do ${code}/district_level_analysis.do





}
