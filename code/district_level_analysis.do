/**********************************************************************/
/*
Evictions & Education | district_level_analysis.do

Performs analysis on district level dataset.
*/
/**********************************************************************/

use ${cleaned_data}/final_district_level_dataset.dta, clear

#delimit ;
local outcome_variables_345 read3rdgrade math3rdgrade read4thgrade math4thgrade
                            read5thgrade math5thgrade;
local outcome_variables_678 read6thgrade math6thgrade read7thgrade math7thgrade
                            read8thgrade math8thgrade;
local controls pctrenteroccupied mediangrossrent medianhouseholdincome
               medianpropertyvalue pctwhite pctafam pcthispanic pctamind
               pctasian pctnhpi pctmultiple pctother enrollment;
#delimit cr
//
// ivregress 2sls math4thgrade (evictionrate=CANO) `controls', cluster(leaid)



//
eststo: xtreg evictionrate CANO pctwhite povertyrate pctrenteroccupied, fe vce(cluster leaid)
// eststo: xtreg evictionfilingrate CANO `controls', fe vce(cluster leaid)
// esttab using ${output_tables}/first_stage_dl.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)
//
//
//
// // MAIN REGRESSIONS
// eststo clear
// // independent variable of interest: eviction rate
// foreach var of varlist `outcome_variables_345' {
//   eststo: xtivreg `var' (evictionrate=CANO) `controls', fe vce(cluster leaid)
// }
// esttab using ${output_tables}/reg_345outcomes_on_eviction_rate_dl.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)
//
// eststo clear
// foreach var of varlist `outcome_variables_678' {
//   eststo:  xtivreg `var' (evictionrate=CANO) `controls', fe vce(cluster leaid)
// }
// esttab using ${output_tables}/reg_678outcomes_on_eviction_rate_dl.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)
//
// eststo clear
// // independent variable of interest: eviction filing rate
// foreach var of varlist `outcome_variables_345' {
//   eststo:  xtivreg `var' (evictionfilingrate=CANO) `controls', fe vce(cluster leaid)
// }
// esttab using ${output_tables}/reg_345outcomes_on_filing_rate_dl.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)
//
// eststo clear
// // independent variable of interest: eviction filing rate
// foreach var of varlist `outcome_variables_678' {
//   eststo:  xtivreg `var' (evictionfilingrate=CANO) `controls', fe vce(cluster leaid)
// }
// esttab using ${output_tables}/reg_678outcomes_on_filing_rate_dl.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)
