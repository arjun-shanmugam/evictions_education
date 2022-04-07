/**********************************************************************/
/*  Evictions & Education ~ main do-file  */
/**********************************************************************/

// set your own path and define globals appropriately
if c(username) == "arjunshanmugam" {

  // RAW DATA
	global raw_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data"
	global kroeger_la_mattina_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/kroeger_la_mattina"
  global leaid_fips_place_crosswalk "/Users/arjunshanmugam/Documents/GitHub/evictions_education/raw_data/grf21_lea_place.xlsx"

  // CLEANED DATA
  global cleaned_data "/Users/arjunshanmugam/Documents/GitHub/evictions_education/cleaned_data"

  // OUTPUT

  // CODE
  global code "/Users/arjunshanmugam/Documents/GitHub/evictions_education/code"

}


// do ${code}/clean_kroeger_la_mattina.do
//
// do ${code}/clean_crosswalk.do

do ${code}/clean_education_data.do
