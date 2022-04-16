/**********************************************************************/
/*
Evictions & Education | city_level_analysis.do

Performs analysis on city level dataset.
*/
/**********************************************************************/
local city_level_analysis


use ${cleaned_data}/final_city_level_dataset.dta, clear


#delimit ;
local outcome_variables_345 read3rdgrade math3rdgrade read4thgrade math4thgrade
                            read5thgrade math5thgrade;
local outcome_variables_678 read6thgrade math6thgrade read7thgrade math7thgrade
                            read8thgrade math8thgrade;
#delimit cr
local controls pctwhite pctrenteroccupied povertyrate

eststo clear
// independent variable of interest: eviction rate
foreach var of varlist `outcome_variables_345' {
  eststo: quietly xtivreg `var' (evictionrate=CANO) `controls', fe vce(robust)
}
esttab using ${output_tables}/reg_345outcomes_on_eviction_rate.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)

eststo clear
foreach var of varlist `outcome_variables_678' {
  eststo: quietly xtivreg `var' (evictionrate=CANO) `controls', fe vce(robust)
}
esttab using ${output_tables}/reg_678outcomes_on_eviction_rate.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)

eststo clear
// independent variable of interest: eviction filing rate
foreach var of varlist `outcome_variables_345' {
  eststo: quietly xtivreg `var' (evictionfilingrate=CANO) `controls', fe vce(robust)
}
esttab using ${output_tables}/reg_345outcomes_on_filing_rate.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)

eststo clear
// independent variable of interest: eviction filing rate
foreach var of varlist `outcome_variables_678' {
  eststo: quietly xtivreg `var' (evictionfilingrate=CANO) `controls', fe vce(robust)
}
esttab using ${output_tables}/reg_678outcomes_on_filing_rate.tex, style(tex) cells(b(star fmt(3)) se(par fmt(2))) replace modelwidth(25)
