/**********************************************************************/
/*
Evictions & Education | city_level_analysis.do

Performs analysis on city level dataset.
*/
/**********************************************************************/
local city_level_analysis


use ${cleaned_data}/final_city_level_dataset.dta, clear


*** setup
// label variables
label variable evictionrate "Eviction rate"  // independent variable of interest
label variable CANO "Presence of CANO"  // instrument
label variable math "Pct. proficient in math"
label variable read "Pct. proficient in reading"
label variable name "Name of place"
label variable pctwhite "Pct. white"  // socioeconomic_controls
label variable povertyrate "Poverty rate"
label variable pctrenteroccupied "Pct. renter-occupied"
// define local to store table options
#delimit ;
local universal_tableopts style(tex) cells(b(fmt(3)) se(par fmt(2))) replace
                          label;
// store controls
local base_controls pctwhite pctrenteroccupied povertyrate mediangrossrent
      medianhouseholdincome medianpropertyvalue;
#delimit cr
local controls_place_fe `base_controls' i.place_fips
local controls_place_year_fe `base_controls' i.place_fips i.year
local controls_place_year_grade_fe `base_controls' i.place_fips i.year i.grade
// drop missing observations and unneeded variables
egen nmissing = rmiss(pctwhite pctrenteroccupied povertyrate evictionrate)
drop if nmissing > 0
keep math read `base_controls' place_fips year grade evictionrate CANO

// FIRST TRY DISTRICT level
// THEN TRY 
*** binscatter plots
graph drop _all
local math_label : variable label math
local read_label : variable label read
local evictionrate_label : variable label evictionrate
#delimit ;
binscatter math evictionrate, name(math_outcome_binscatter)
                              reportreg
                              xtitle(`evictionrate_label')
                              ytitle(`math_label')
                              ylabel(70(2)86);
binscatter read evictionrate, name(read_outcome_binscatter)
                              reportreg
                              xtitle(`evictionrate_label')
                              ytitle(`read_label')
                              ylabel(70(2)86);
graph combine math_outcome_binscatter read_outcome_binscatter,
      title("Correlation Between Proficiency and Eviction Rate");
graph export ${output_graphs}/outcome_binscatter.png, replace;
#delimit cr


// map of eviction rates next to map of poverty

// prove that CANO is a good instrument in some way


*** first stage
eststo clear
eststo: regress evictionrate CANO, cluster(place_fips)
estadd local socioeconomic_controls "No"
estadd local place_fe "No"
estadd local year_fe "No"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// socioeconomic controls
eststo: regress evictionrate CANO `base_controls', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "No"
estadd local year_fe "No"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// socioeconomic controls and place FE
eststo: regress evictionrate CANO `controls_place_fe', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "Yes"
estadd local year_fe "No"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// socioeconomic controls and place and year fe
eststo: regress evictionrate CANO `controls_place_year_fe', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "Yes"
estadd local year_fe "Yes"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// socioeconomic controls and place, year, and grade fe
eststo: regress evictionrate CANO `controls_place_year_grade_fe', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "Yes"
estadd local year_fe "Yes"
estadd local grade_fe "Yes"
estadd scalar districts = e(N_clust)
#delimit ;
esttab using ${output_tables}/cl_first_stage.tex,
             `universal_tableopts'
             keep(CANO)
             mlabels("Eviction rate" "Eviction rate" "Eviction Rate" "Eviction Rate" "Eviction Rate", nonumbers)
             scalars("districts Number of clusters"
                     "socioeconomic_controls Socioeconomic controls"
                     "place_fe Place F.E."
                     "year_fe Year F.E."
                     "grade_fe Grade F.E.")
             title("First Stage Regresions");
#delimit cr



*** math main outcomes NOTE: WHAT IS THE BEST WAY TO ORDER COLUMNS/WHAT MODELS MAKE SENSE TO RUN?
eststo clear
// OLS with controls
eststo: regress math evictionrate `base_controls', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "No"
estadd local year_fe "No"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// IV with controls
eststo: ivregress 2sls math (evictionrate=CANO) `base_controls', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "No"
estadd local year_fe "No"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// IV with controls, place FE
eststo: ivregress 2sls math (evictionrate=CANO) `controls_place_fe', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "Yes"
estadd local year_fe "No"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// IV with controls, place FE, year FE
eststo: ivregress 2sls math (evictionrate=CANO) `controls_place_year_fe', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "Yes"
estadd local year_fe "Yes"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// IV with controls, place FE, year FE, grade FE
eststo: ivregress 2sls math (evictionrate=CANO) `controls_place_year_grade_fe', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "Yes"
estadd local year_fe "Yes"
estadd local grade_fe "Yes"
estadd scalar districts = e(N_clust)
#delimit ;
esttab using ${output_tables}/cl_math_main_results.tex,
             `universal_tableopts'
             keep(evictionrate)
             mlabels("Eviction rate" "Eviction rate" "Eviction Rate" "Eviction Rate" "Eviction Rate", nonumbers)
             scalars("districts Number of clusters"
                     "socioeconomic_controls Socioeconomic controls"
                     "place_fe Place F.E."
                     "year_fe Year F.E."
                     "grade_fe Grade F.E.")
             title("OLS and Instrumental Variable Regressions");
#delimit cr


*** reading main outcomes
eststo clear
// OLS with controls
eststo: regress read evictionrate `base_controls', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "No"
estadd local year_fe "No"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// IV with controls
eststo: ivregress 2sls read (evictionrate=CANO) `base_controls', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "No"
estadd local year_fe "No"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// IV with controls, place FE
eststo: ivregress 2sls read (evictionrate=CANO) `controls_place_fe', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "Yes"
estadd local year_fe "No"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// IV with controls, place FE, year FE
eststo: ivregress 2sls read (evictionrate=CANO) `controls_place_year_fe', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "Yes"
estadd local year_fe "Yes"
estadd local grade_fe "No"
estadd scalar districts = e(N_clust)
// IV with controls, place FE, year FE, grade FE
eststo: ivregress 2sls read (evictionrate=CANO) `controls_place_year_grade_fe', cluster(place_fips)
estadd local socioeconomic_controls "Yes"
estadd local place_fe "Yes"
estadd local year_fe "Yes"
estadd local grade_fe "Yes"
estadd scalar districts = e(N_clust)
#delimit ;
esttab using ${output_tables}/cl_read_main_results.tex,
             `universal_tableopts'
             keep(evictionrate)
             mlabels("Eviction rate" "Eviction rate" "Eviction Rate" "Eviction Rate" "Eviction Rate" "Eviction Rate", nonumbers)
             scalars("districts Number of clusters"
                     "socioeconomic_controls Socioeconomic controls"
                     "place_fe Place F.E."
                     "year_fe Year F.E."
                     "grade_fe Grade F.E.")
             title("OLS and Instrumental Variable Regressions");
#delimit cr
