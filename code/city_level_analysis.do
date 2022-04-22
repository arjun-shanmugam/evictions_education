/**********************************************************************/
/*
Evictions & Education | city_level_analysis.do

Performs analysis on city level dataset.
*/
/**********************************************************************/
local city_level_analysis


use ${cleaned_data}/final_city_level_dataset.dta, clear



#delimit ;
local math_outcomes  math3rdgrade math4thgrade math5thgrade
                     math6thgrade math7thgrade math8thgrade;
local reading_outcomes read3rdgrade read4thgrade read5thgrade
                       read6thgrade read7thgrade read8thgrade;
#delimit cr
local controls pctwhite pctrenteroccupied povertyrate i.place_fips
egen nmissing = rmiss(pctwhite pctrenteroccupied povertyrate evictionrate evictionfilingrate)
drop if nmissing > 0

// first stage
regress evictionrate CANO `controls', cluster(place_fips)


// math outcomes on eviction rate
eststo clear
foreach var of varlist `math_outcomes' {
  eststo: ivregress 2sls `var'  (evictionrate=CANO) `controls', cluster(place_fips)
}
esttab using ${output_tables}/cl_math_on_eviction_rate.tex, keep(evictionrate) style(tex) cells(b(fmt(3)) se(par fmt(2))) replace modelwidth(25)

// math outcomes on eviction filing rate
eststo clear
foreach var of varlist `math_outcomes' {
  eststo: ivregress 2sls `var' (evictionfilingrate=CANO) `controls', cluster(place_fips)
}
esttab using ${output_tables}/cl_math_on_eviction_filing_rate.tex, keep(evictionfilingrate) style(tex) cells(b(fmt(3)) se(par fmt(2))) replace modelwidth(25)

// reading_outcomes on eviction rate
eststo clear
foreach var of varlist `reading_outcomes' {
  eststo: ivregress 2sls `var'  (evictionrate=CANO) `controls', cluster(place_fips)
}
esttab using ${output_tables}/cl_reading_on_eviction_rate.tex, keep(evictionrate) style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)

// reading outcomes on evictionfilingrate
eststo clear
foreach var of varlist `reading_outcomes' {
  eststo: ivregress 2sls `var'  (evictionfilingrate=CANO) `controls', cluster(place_fips)
}
esttab using ${output_tables}/cl_reading_on_eviction_filing_rate.tex, keep(evictionfilingrate) style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)



// eststo clear
// foreach var of varlist `math_outcomes' {
// eststo: ivregress 2sls `var' (evictionrate=CANO) `controls' i.fips, cluster(fips)
// }
// esttab using ${output_tables}/math_outcomes_on_eviction_rate_cl.tex, keep(evictionrate) style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)
//
//
// eststo clear
// foreach var of varlist `reading_outcomes' {
// eststo: ivregress 2sls `var' (evictionfilingrate=CANO) `controls' i.fips, cluster(fips)
// }
// esttab using ${output_tables}/reading_outcomes_on_eviction_rate_cl.tex, keep(evictionfilingrate) style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)


/*
eststo: xtreg evictionrate CANO `controls', fe vce(cluster fips)
eststo: xtreg evictionfilingrate CANO `controls', fe vce(cluster fips)
esttab using ${output_tables}/first_stage.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)


// MAIN REGRESSIONS
eststo clear
// independent variable of interest: eviction rate
foreach var of varlist `outcome_variables_345' {
  eststo: xtivreg `var' (evictionrate=CANO) `controls', fe vce(cluster fips)
}
esttab using ${output_tables}/reg_345outcomes_on_eviction_rate.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)

eststo clear
foreach var of varlist `outcome_variables_678' {
  eststo: xtivreg `var' (evictionrate=CANO) `controls', fe vce(cluster fips)
}
esttab using ${output_tables}/reg_678outcomes_on_eviction_rate.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)

eststo clear
// independent variable of interest: eviction filing rate
foreach var of varlist `outcome_variables_345' {
  eststo: xtivreg `var' (evictionfilingrate=CANO) `controls', fe vce(cluster fips)
}
esttab using ${output_tables}/reg_345outcomes_on_filing_rate.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)

eststo clear
// independent variable of interest: eviction filing rate
foreach var of varlist `outcome_variables_678' {
  eststo: xtivreg `var' (evictionfilingrate=CANO) `controls', fe vce(cluster fips)
}
esttab using ${output_tables}/reg_678outcomes_on_filing_rate.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)
*/
