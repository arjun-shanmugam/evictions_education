/**********************************************************************/
/*
Evictions & Education | city_level_analysis.do

Performs analysis on city level dataset.
*/
/**********************************************************************/
local city_level_analysis


use ${cleaned_data}/final_city_level_dataset.dta, clear

bysort place_fips grade: generate math2 = math[_n+1]
bysort place_fips grade: generate read2 = read[_n+1]

*** setup
// label variables
label variable evictionrate "\hspace{0.25cm} Eviction rate"  // independent variable of interest
label variable CANO "\hspace{0.25cm} Presence of CANO"  // instrument
label variable math "\hspace{0.25cm} Pct. proficient in math"
label variable read "\hspace{0.25cm} Pct. proficient in reading"
label variable name "\hspace{0.25cm} Name of place"
label variable pctwhite "\hspace{0.25cm} Pct. white"  // socioeconomic_controls
label variable povertyrate "\hspace{0.25cm} Poverty rate"
label variable pctrenteroccupied "\hspace{0.25cm} Pct. renter-occupied"
label variable year "\hspace{0.25cm} Year"
label variable grade "\hspace{0.25cm} Grade year"
label variable medianhouseholdincome "\hspace{0.25cm} Median household income"
label variable medianpropertyvalue "\hspace{0.25cm} Median property value"


// define local to store table options
#delimit ;
local universal_tableopts cells(b(fmt(3)) se(par fmt(2))) replace
                          label;
// store controls
local base_controls pctwhite pctrenteroccupied povertyrate medianhouseholdincome
                    medianpropertyvalue;
#delimit cr
local controls_place_year_grade_fe `base_controls' i.place_fips i.year i.grade

// drop missing observations and unneeded variables
egen nmissing = rmiss(pctwhite pctrenteroccupied povertyrate evictionrate)
drop if nmissing > 0
keep math read `base_controls' place_fips year grade evictionrate population name

//
// // *** summary statistics
// eststo clear
// #delimit ;
// estpost tabstat math read evictionrate grade medianhouseholdincome
//                 medianpropertyvalue pctrenteroccupied pctwhite povertyrate year,
//                 c(stat) stat(mean sd min max n);
// esttab using ${output_tables}/summary_stats.tex,
//   replace refcat(math "\emph{Dependent variables}"
//                  evictionrate "\vspace{0.1em} \\ \emph{Independent variable of interest}"
//                  grade "\vspace{0.1em} \\ \emph{Control variables}", nolabel)
//   cells("mean(fmt(2 2 2 0 2 2 2 2 2 0)) sd min max count(fmt(0))") nomtitle
//   noobs label nonumber booktabs
//   collabels("Mean" "SD" "Min" "Max" "N") title("Descriptive Statistics")
//   addnotes("Note: This table presents descriptive statistics for the sample. Descriptive statistics for \emph{Grade year} and \emph{Year} are "
//   "truncated to have zero decimal places. Values of independent and control variables are from the current year; values"
//   "of dependent variables are from the following year.");
// #delimit cr
//
//
// // *** binscatter plots
// // relabel to remove latex code
// label variable math "Pct. proficient in math"
// label variable read "Pct. proficient in reading"
// label variable evictionrate "Eviction rate"
// graph drop _all
// local math_label : variable label math
// local read_label : variable label read
// local evictionrate_label : variable label evictionrate
// #delimit ;
// binscatter math evictionrate, name(math_outcome_binscatter)
//                               reportreg
//                               xtitle(`evictionrate_label')
//                               ytitle(`math_label')
//                               ylabel(70(2)86);
// binscatter read evictionrate, name(read_outcome_binscatter)
//                               reportreg
//                               xtitle(`evictionrate_label')
//                               ytitle(`read_label')
//                               ylabel(70(2)86);
// graph combine math_outcome_binscatter read_outcome_binscatter,
//       title("Correlation Between Proficiency and Eviction Rate")
//       note("Note: These figures present raw correlations between proficiency rates and eviction rates. Observations in"
//            "each figure are binned into 20 equal size bins (five percentile points each). The solid line shows the best"
//            "linear fit estimated on the underlying city-year-grade-level data using OLS.");
// graph export ${output_graphs}/outcome_binscatter.png, replace;
// #delimit cr
//
//
// *** map of eviction rates next to map of poverty
// preserve
// graph drop _all
// #delimit ;
// collapse (mean) math read evictionrate pctwhite povertyrate pctrenteroccupied
//                 medianhouseholdincome medianpropertyvalue, by(place_fips);
// #delimit cr
//
//
// merge 1:m place_fips using ${cleaned_data}/city_db.dta
// /*
// Result                      Number of obs
// -----------------------------------------
// Not matched                            15
//     from master                         0  (_merge==1)
//     from using                         15  (_merge==2)
//
// Matched                             1,189  (_merge==3)
// -----------------------------------------
// _merge == 2:
//   There are some cities which appear in the Census shapefile but not in our data
// */
// local labels label(1 "No data") label(2 "4th quartile") label(3 "3rd quartile") label(4 "2nd quartile") label(5 "1st quartile")
// #delimit ;
// spmap evictionrate using ${cleaned_data}/ohio_coord.dta, id(id)
//                                                          fcolor(Blues)
//                                                          title(Eviction Rate)
//                                                          name(eviction_map)
//                                                          legend( `labels' pos(5) size(2.5) region(fcolor(white) lcolor(black))) ;
//
//
//
// spmap math using ${cleaned_data}/ohio_coord.dta, id(id)
//   fcolor(Blues)
//     title(Pct. Proficient in Math)
//     name(math_map)
//   legend( `labels' pos(5) size(2.5) region(fcolor(white) lcolor(black))) ;
// spmap read using ${cleaned_data}/ohio_coord.dta, id(id)
//                                                          fcolor(Blues)
//                                                          title(Pct. Proficient in Reading)
//                                                          name(reading_map)
//
//                                                          legend( `labels' pos(5) size(2.5) region(fcolor(white) lcolor(black))) ;
// spmap povertyrate using ${cleaned_data}/ohio_coord.dta, id(id)
//                                                      fcolor(Blues)
//                                                      title(Poverty Rate)
//                                                      name(povertyrate_map)
//                                                      legend( `labels' pos(4) size(2.5) region(fcolor(white) lcolor(black)));
// spmap pctrenteroccupied using ${cleaned_data}/ohio_coord.dta, id(id)
//                                                               fcolor(Blues)
//                                                               title(Pct. Renter Occupied)
//                                                               name(pctrenteroccupied_map)
//
//
//                                                               legend( `labels' pos(4) size(2.5) region(fcolor(white) lcolor(black)))
//                                                             ;
// spmap medianhouseholdincome using ${cleaned_data}/ohio_coord.dta, id(id)
//                                                                                                                           fcolor(Blues)
//                                                                                                                           title(Median Household Income)
//                                                                                                                           name(medianhouseholdincome_map)
//
//
//                                                                                                                           legend( `labels' pos(4) size(2.5) region(fcolor(white) lcolor(black)))
//                                                                                                                         ;
//
// graph combine math_map reading_map eviction_map povertyrate_map pctrenteroccupied_map medianhouseholdincome_map,
//   title("Spatial Distribution of Dependent Variables, Treatment, and Select Covariates" "(Cuyahoga County)", size(medium))
//   note("Note: These heatmaps present the distributions the dependent variables, treatment, and select covariates"
//        "over observed cities. To produce each map, I first calculate city means of each variable over the sample"
//        "period. Then, according to these mean values of each variable, I sort cities into 4 bins of equal sizes. Cities"
//        "are then colored according to what bin they fall into.");
// #delimit cr
// graph export ${output_graphs}/maps.png, replace
// restore
//
//
//
//
// // *** main regression results
// local outcomes math read
// eststo clear
// foreach var of varlist `outcomes' {
//   // socioeconomic controls, no F.E.
//   eststo: regress `var' evictionrate i.place_fips, cluster(place_fips)
//   estadd local socioeconomic_controls "No"
//   estadd local place_fe "Yes"
//   estadd local year_fe "No"
//   estadd local grade_fe "No"
//   estadd scalar districts = e(N_clust)
//   // socioeconomic controls, place FE
//   eststo: regress `var' evictionrate i.place_fips i.year, cluster(place_fips)
//   estadd local socioeconomic_controls "No"
//   estadd local place_fe "Yes"
//   estadd local year_fe "Yes"
//   estadd local grade_fe "No"
//   estadd scalar districts = e(N_clust)
//   // socioeconomic controls, place FE, year FE
//   eststo: regress `var' evictionrate i.place_fips i.year i.grade, cluster(place_fips)
//   estadd local socioeconomic_controls "No"
//   estadd local place_fe "Yes"
//   estadd local year_fe "Yes"
//   estadd local grade_fe "Yes"
//   estadd scalar districts = e(N_clust)
//   // socioeconomic controls, place FE, year FE, grade FE
//   eststo: regress `var' evictionrate `controls_place_year_grade_fe', cluster(place_fips)
//   estadd local socioeconomic_controls "Yes"
//   estadd local place_fe "Yes"
//   estadd local year_fe "Yes"
//   estadd local grade_fe "Yes"
//   estadd scalar districts = e(N_clust)
//
//
//
//
//
// }
// #delimit ;
// esttab using ${output_tables}/main_regressions.tex,
//              `universal_tableopts'
//              keep(evictionrate)
//              mgroups("Pct. proficient in math" "Pct. proficient in reading", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
//              nomtitles booktabs
//              eqlabels(none)
//              scalars("districts Number of clusters"
//                      "r2 $\text{R}^2$"
//
//                      "place_fe Place F.E."
//                      "year_fe Year F.E."
//                      "grade_fe Grade F.E."
//                      "socioeconomic_controls Socioeconomic controls")
//              title("Main Results")
//              addnotes("Note: This table presents OLS regression estimates of the effect of \emph{eviction rate} on mathematics and reading"
//                       "proficiency rates. Each column represents one regression. Robust standard errors are clustered"
//                     "at the city level.");
// #delimit cr
//
//
//
//
// *** Heterogeneous Treatment Effects
// local socioeconomic_vars pctwhite medianhouseholdincome medianpropertyvalue povertyrate pctrenteroccupied
// local colors green lavender red orange
// estimates clear
// foreach curr_var of varlist `socioeconomic_vars' {
//
//
// 	summarize `curr_var', detail
// 	scalar fiftieth_percentile = r(p50)
//  	// math, above 50th percentile
// 	regress math evictionrate `controls_place_year_grade_fe' if `curr_var' > fiftieth_percentile, cluster(place_fips)
// 	estimates store m_h_`curr_var'
// 	// math, below 50th percentile
// 	regress math evictionrate `controls_place_year_grade_fe' if `curr_var' <= fiftieth_percentile, cluster(place_fips)
// 	estimates store m_l_`curr_var'
//
//
// 	// read, above 50th percentile
// 	regress read evictionrate `controls_place_year_grade_fe' if `curr_var' > fiftieth_percentile, cluster(place_fips)
// 	estimates store r_h_`curr_var'
// 	// read, below 50th percentile
// 	regress read evictionrate `controls_place_year_grade_fe' if `curr_var' <= fiftieth_percentile, cluster(place_fips)
// 	estimates store r_l_`curr_var'
//
//
// 	local math_modelnames `math_modelnames' (m_h_`curr_var', mcolor(red) ciopts(color(red))) (m_l_`curr_var', mcolor(blue) ciopts(color(blue)))
// 	local read_modelnames `read_modelnames' (r_h_`curr_var', mcolor(red) ciopts(color(red))) (r_l_`curr_var', mcolor(blue) ciopts(color(blue)))
//
// }
//
// #delimit ;
// coefplot `math_modelnames',
// 	keep(evictionrate)
// 	asequation
// 	swapnames
// 	eqrename(m_h_pctwhite = "High pct. white sample"
// 			 m_l_pctwhite = "Low pct. white sample"
// 			 m_h_medianhouseholdincome = "High median household income sample"
// 			 m_l_medianhouseholdincome = "Low median household income sample"
// 			 m_h_medianpropertyvalue = "High median property value sample"
// 			 m_l_medianpropertyvalue = "Low median property value sample"
// 			 m_h_povertyrate = "High poverty rate sample"
// 			 m_l_povertyrate = "Low poverty rate sample"
// 			 m_h_pctrenteroccupied = "High pct. renter occupied sample"
// 			 m_l_pctrenteroccupied = "Low pct. renter occupied sample")
// 	ylabel(, labsize(small))
// 	yline(2.5 4.5 6.5 8.5, lcolor(black) lpattern(dash))
// 	xline(0, lcolor(black))
// 	legend(cols(1) order(2 "Regressions on observations above median" 4 "Regressions on observations below median"))
// 	title("Heterogeneous Treatment Effects, Math");
// graph export ${output_graphs}/math_heterogeneous_effects.png, replace;
//
// coefplot `read_modelnames',
// 	keep(evictionrate)
// 	asequation
// 	swapnames
// 	eqrename(r_h_pctwhite = "High pct. white sample"
// 			 r_l_pctwhite = "Low pct. white sample"
// 			 r_h_medianhouseholdincome = "High median household income sample"
// 			 r_l_medianhouseholdincome = "Low median household income sample"
// 			 r_h_medianpropertyvalue = "High median property value sample"
// 			 r_l_medianpropertyvalue = "Low median property value sample"
// 			 r_h_povertyrate = "High poverty rate sample"
// 			 r_l_povertyrate = "Low poverty rate sample"
// 			 r_h_pctrenteroccupied = "High pct. renter occupied sample"
// 			 r_l_pctrenteroccupied = "Low pct. renter occupied sample")
// 	ylabel(, labsize(small))
// 	yline(2.5 4.5 6.5 8.5, lcolor(black) lpattern(dash))
// 	xline(0, lcolor(black))
// 	legend(cols(1) order(2 "Regressions on observations above median" 4 "Regressions on observations below median"))
// 	title("Heterogeneous Treatment Effects, Reading");
// graph export ${output_graphs}/read_heterogeneous_effects.png, replace;
// #delimit cr
//
// *** how much variation is explained by controls?
// local independent_var_and_dependent math read evictionrate
// eststo clear
//
// foreach var of varlist `independent_var_and_dependent' {
//   // all fe controls
//   eststo: regress `var' i.place_fips i.year i.grade, cluster(place_fips)
//   estadd local pct_white "No"
//   estadd local poverty_rate "No"
//   estadd local pct_renter_occupied "No"
//   estadd local median_household_income "No"
//   estadd local median_property_value "No"
//   estadd local bold_r2 "\textbf{`: di %9.4f e(r2)'}"
//   estadd scalar districts = e(N_clust)
//   // all fe, pct white
//   eststo: regress `var' pctwhite i.place_fips i.year i.grade, cluster(place_fips)
//   estadd local pct_white "Yes"
//   estadd local poverty_rate "No"
//   estadd local pct_renter_occupied "No"
//   estadd local median_household_income "No"
//   estadd local median_property_value "No"
//   estadd local bold_r2 "\textbf{`: di %9.4f e(r2)'}"
//   estadd scalar districts = e(N_clust)
//   // all fe, pct white, poverty rate
//   eststo: regress `var' pctwhite povertyrate i.place_fips i.year i.grade, cluster(place_fips)
//   estadd local pct_white "Yes"
//   estadd local poverty_rate "Yes"
//   estadd local pct_renter_occupied "No"
//   estadd local median_household_income "No"
//   estadd local median_property_value "No"
//   estadd local bold_r2 "\textbf{`: di %9.4f e(r2)'}"
//   estadd scalar districts = e(N_clust)
//   // all fe, pct white, poverty rate, pct renter occupied
//   eststo: regress `var' pctwhite povertyrate pctrenteroccupied i.place_fips i.year i.grade, cluster(place_fips)
//   estadd local pct_white "Yes"
//   estadd local poverty_rate "Yes"
//   estadd local pct_renter_occupied "Yes"
//   estadd local median_household_income "No"
//   estadd local median_property_value "No"
//   estadd local bold_r2 "\textbf{`: di %9.4f e(r2)'}"
//   estadd scalar districts = e(N_clust)
//   // // all fe, pct white, poverty rate, pct renter occupied, median household income
//   // eststo: regress `var' pctwhite povertyrate pctrenteroccupied medianhouseholdincome i.place_fips i.year i.grade, cluster(place_fips)
//   // estadd local pct_white "Yes"
//   // estadd local poverty_rate "Yes"
//   // estadd local pct_renter_occupied "Yes"
//   // estadd local median_household_income "Yes"
//   // estadd local median_property_value "No"
//   // estadd local bold_r2 "\textbf{`: di %9.3f e(r2)'}"
//   // estadd scalar districts = e(N_clust)
//   // // all fe, pct white, poverty rate, pct renter occupied, median household income, median prop value
//   // eststo: regress `var' pctwhite povertyrate pctrenteroccupied medianhouseholdincome medianpropertyvalue i.place_fips i.year i.grade, cluster(place_fips)
//   // estadd local pct_white "Yes"
//   // estadd local poverty_rate "Yes"
//   // estadd local pct_renter_occupied "Yes"
//   // estadd local median_household_income "Yes"
//   // estadd local median_property_value "Yes"
//   // estadd local bold_r2 "\textbf{`: di %9.3f e(r2)'}"
//   // estadd scalar districts = e(N_clust)
//
//
// }
//
// #delimit ;
// esttab using ${output_tables}/predictive_ability_of_controls.tex,
//              `universal_tableopts'
//              mgroups("Pct. proficient in math" "Pct. proficient in reading" "Eviction rate", pattern(1 0 0 0 1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
//              nomtitles booktabs
//              eqlabels(none)
//              keep(pctwhite povertyrate pctrenteroccupied)
//              scalars("bold_r2 $\mathbf{R^2}$"
//                      "pct_white Controls for \emph{pct. white}?"
//                      "poverty_rate \emph{Poverty rate}?"
//                      "pct_renter_occupied \emph{Pct. renter occupied}?"
//                      "districts Number of clusters"
//
//                         )
//              title("Predictive Ability of Controls")
//              addnotes(
//                       "Note: This table presents OLS regressions of math proficiency rates, reading proficiency rates, and eviction rates on different combinations of controls."
//               " Each column represents one regression. All regressions include city, year, and grade fixed effects. Robust standard errors are clustered at the city level. "
//             "For space reasons, I exclude two controls from these estimates; they did not alter $\text{R}^2$ values.")
//                     ;
// #delimit cr


*** Oster (2016) estimator for bias-adjusted treatment effects
local pis 1.1 1.2 1.3 1.4 1.5
matrix oster = (., ., ., ., .)
regress math evictionrate `controls_place_year_grade_fe', cluster(place_fips)
forvalues col = 1/5 {
local curr_pi : word `col' of `pis'
scalar curr_pi = `curr_pi'
psacalc delta evictionrate, rmax(`=curr_pi * e(r2)') beta(0)
matrix oster[1, `col'] = r(delta)
}
matrix rownames oster = "$\delta"
matrix colnames oster =  " $ R_{max} = 1.1*\tilde{R} = `:display %10.2f  `=1.1*e(r2)''$" " $ R_{max} = 1.2*\tilde{R} = `:display %10.2f  `=1.2*e(r2)''$" " $ R_{max} = 1.3*\tilde{R} = `:display %10.2f  `=1.3*e(r2)''$" " $ R_{max} = 1.4*\tilde{R} = `:display %10.2f  `=1.4*e(r2)''$" " $ R_{max} = 1.5*\tilde{R} = `:display %10.2f  `=1.5*e(r2)''$"
#delimit ;
esttab matrix(oster) using ${output_tables}/oster_2016_analysis.tex,
	title("Relative Degree of Selection on Observables and Unobservables Necessary to Eliminate Treatment Effects")
	replace
  booktabs
  nomtitles
  substitute(\_ _)
	;
#delimit cr
