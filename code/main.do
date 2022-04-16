/**********************************************************************/
/*  Evictions & Education ~ main do-file  */
/**********************************************************************/

// set your own path and define globals appropriately
if c(username) == "arjunshanmugam" {

  // RAW DATA
	global raw_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data"
	global kroeger_la_mattina_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/kroeger_la_mattina"
  global leaid_fips_place_crosswalk "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/grf21_lea_place.xlsx"
	global ohioid_leaid_crosswalk "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/ncesdata_7C561E22.xlsx"

  // CLEANED DATA
  global cleaned_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/cleaned_data"

  // OUTPUT
	global output_tables "/Users/arjunshanmugam/Documents/GitHub/evictions_education/output/tables"

  // CODE
  global code "/Users/arjunshanmugam/Documents/GitHub/evictions_education/code"

}

local city_level 1
local district_level 0

if `city_level' {
do ${code}/clean_kroeger_la_mattina.do

do ${code}/clean_leaid_fips_crosswalk.do

do ${code}/clean_ohioid_leaid_crosswalk.do

do ${code}/clean_education_data.do

do ${code}/merge_to_city_level.do

do ${code}/city_level_analysis.do
}

if `district_level' {
	do ${code}/clean_kroeger_la_mattina.do

	do ${code}/clean_education_data.do

	do ${code}/clean_ohioid_leaid_crosswalk.do

	// TODO: clean crosswalk from leaid to census tract

	// TODO: clean eviction data

	// TODO: merge data and allocate evictions to school districts 




}
