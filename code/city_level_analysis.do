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
label variable evictionrate "\hspace{0.25cm} Eviction rate"  // independent variable of interest
label variable CANO "\hspace{0.25cm} Presence of CANO"  // instrument
label variable math "\hspace{0.25cm} Pct. proficient in math, following year"
label variable read "\hspace{0.25cm} Pct. proficient in reading, following year"
label variable name "\hspace{0.25cm} Name of place"
label variable pctwhite "\hspace{0.25cm} Pct. white"  // socioeconomic_controls
label variable povertyrate "\hspace{0.25cm} Poverty rate"
label variable pctrenteroccupied "\hspace{0.25cm} Pct. renter-occupied"
label variable year "\hspace{0.25cm} Year"
label variable grade "\hspace{0.25cm} Grade year"
label variable medianhouseholdincome "\hspace{0.25cm} Median household income"
label variable medianpropertyvalue "\hspace{0.25cm} Median property value"
label variable pct_with_bachelors "\hspace{0.25cm} Pct. with bachelor's degree"

// define local to store table options
#delimit ;
local universal_tableopts cells(b(fmt(3)) se(par fmt(2))) replace
                          label;
// store controls
local base_controls pctwhite pctrenteroccupied povertyrate medianhouseholdincome
                    medianpropertyvalue pct_with_bachelors;
#delimit cr
local controls_place_year_grade_fe `base_controls' i.place_fips i.year i.grade

// drop missing observations and unneeded variables
egen nmissing = rmiss(pctwhite pctrenteroccupied povertyrate evictionrate)
drop if nmissing > 0
keep math read `base_controls' place_fips year grade evictionrate population

// *** summary statistics
#delimit ;
estpost tabstat math read evictionrate grade medianhouseholdincome
                medianpropertyvalue pctrenteroccupied pctwhite pct_with_bachelors povertyrate year,
                c(stat) stat(mean sd min max n);
esttab using ${output_tables}/summary_stats.tex,
  replace refcat(math "\emph{Dependent variables}"
                 evictionrate "\vspace{0.1em} \\ \emph{Independent variable of interest}"
                 grade "\vspace{0.1em} \\ \emph{Control variables}", nolabel)
  cells("mean(fmt(2 2 2 0 2 2 2 2 2 2 0)) sd min max count(fmt(0))") nomtitle
  noobs label nonumber booktabs
  collabels("Mean" "SD" "Min" "Max" "N") title("Descriptive Statistics")
  addnotes("Note: This table presents descriptive statistics for the sample. Descriptive statistics for \emph{Grade year} and" "\emph{Year} are truncated to have zero decimal places.");
#delimit cr


// *** binscatter plots
// relabel to remove latex code
label variable math "Pct. proficient in math"
label variable read "Pct. proficient in reading"
label variable evictionrate "Eviction rate"
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
      title("Correlation Between Proficiency and Eviction Rate")
      note("Note: These figures present raw correlations between proficiency rates and eviction rates. Observations in"
           "each figure are binned into 20 equal size bins (five percentile points each). The solid line shows the best"
           "linear fit estimated on the underlying city-year-grade-level data using OLS.");
graph export ${output_graphs}/outcome_binscatter.png, replace;
#delimit cr


*** map of eviction rates next to map of poverty
preserve
graph drop _all
#delimit ;
collapse (mean) math read evictionrate pctwhite povertyrate pctrenteroccupied
                medianhouseholdincome medianpropertyvalue, by(place_fips);
#delimit cr


merge 1:m place_fips using ${cleaned_data}/city_db.dta
/*
Result                      Number of obs
-----------------------------------------
Not matched                            15
    from master                         0  (_merge==1)
    from using                         15  (_merge==2)

Matched                             1,189  (_merge==3)
-----------------------------------------
_merge == 2:
  There are some cities which appear in the Census shapefile but not in our data
*/
local labels label(1 "No data") label(2 "4th quartile") label(3 "3rd quartile") label(4 "2nd quartile") label(5 "1st quartile")
#delimit ;
spmap evictionrate using ${cleaned_data}/ohio_coord.dta, id(id)
                                                         fcolor(Blues)
                                                         title(Eviction Rate)
                                                         name(eviction_map)
                                                         legend( `labels' pos(5) size(2.5) region(fcolor(white) lcolor(black))) ;



spmap math using ${cleaned_data}/ohio_coord.dta, id(id)
  fcolor(Blues)
    title(Pct. Proficient in Math)
    name(math_map)
  legend( `labels' pos(5) size(2.5) region(fcolor(white) lcolor(black))) ;
spmap read using ${cleaned_data}/ohio_coord.dta, id(id)
                                                         fcolor(Blues)
                                                         title(Pct. Proficient in Reading)
                                                         name(reading_map)

                                                         legend( `labels' pos(5) size(2.5) region(fcolor(white) lcolor(black))) ;
spmap povertyrate using ${cleaned_data}/ohio_coord.dta, id(id)
                                                     fcolor(Blues)
                                                     title(Poverty Rate)
                                                     name(povertyrate_map)
                                                     legend( `labels' pos(4) size(2.5) region(fcolor(white) lcolor(black)));
spmap pctrenteroccupied using ${cleaned_data}/ohio_coord.dta, id(id)
                                                              fcolor(Blues)
                                                              title(Pct. Renter Occupied)
                                                              name(pctrenteroccupied_map)


                                                              legend( `labels' pos(4) size(2.5) region(fcolor(white) lcolor(black)))
                                                            ;
spmap medianhouseholdincome using ${cleaned_data}/ohio_coord.dta, id(id)
                                                                                                                          fcolor(Blues)
                                                                                                                          title(Median Household Income)
                                                                                                                          name(medianhouseholdincome_map)


                                                                                                                          legend( `labels' pos(4) size(2.5) region(fcolor(white) lcolor(black)))
                                                                                                                        ;

graph combine math_map reading_map eviction_map povertyrate_map pctrenteroccupied_map medianhouseholdincome_map,
  title("Spatial Distribution of Dependent Variables, Treatment, and Select Covariates" "(Cuyahoga County)", size(medium))
  note("Note: These heatmaps present the distributions the dependent variables, treatment, and select covariates"
       "over observed cities. To produce each map, I first calculate mean values of each variable over the sample"
       "period. Then, according to these mean values of each variable, I sort cities into 4 bins of equal sizes. Cities"
       "are then colored according to what bin they fall into.");
#delimit cr
graph export ${output_graphs}/maps.png, replace
restore




// *** main regression results
local outcomes math read
eststo clear
foreach var of varlist `outcomes' {
  // socioeconomic controls, no F.E.
  eststo: regress `var' evictionrate i.place_fips, cluster(place_fips)
  estadd local socioeconomic_controls "No"
  estadd local place_fe "Yes"
  estadd local year_fe "No"
  estadd local grade_fe "No"
  estadd scalar districts = e(N_clust)
  // socioeconomic controls, place FE
  eststo: regress `var' evictionrate i.place_fips i.year, cluster(place_fips)
  estadd local socioeconomic_controls "No"
  estadd local place_fe "Yes"
  estadd local year_fe "Yes"
  estadd local grade_fe "No"
  estadd scalar districts = e(N_clust)
  // socioeconomic controls, place FE, year FE
  eststo: regress `var' evictionrate i.place_fips i.year i.grade, cluster(place_fips)
  estadd local socioeconomic_controls "No"
  estadd local place_fe "Yes"
  estadd local year_fe "Yes"
  estadd local grade_fe "Yes"
  estadd scalar districts = e(N_clust)
  // socioeconomic controls, place FE, year FE, grade FE
  eststo: regress `var' evictionrate `controls_place_year_grade_fe', cluster(place_fips)
  estadd local socioeconomic_controls "Yes"
  estadd local place_fe "Yes"
  estadd local year_fe "Yes"
  estadd local grade_fe "Yes"
  estadd scalar districts = e(N_clust)
}
#delimit ;
esttab using ${output_tables}/main_regressions.tex,
             `universal_tableopts'
             keep(evictionrate)
             mgroups("Pct. Proficient in Math" "Pct. Proficient in Reading", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
             nomtitles booktabs
             eqlabels(none)
             scalars("districts Number of clusters"
                     "r2 $\text{R}^2$"

                     "place_fe Place F.E."
                     "year_fe Year F.E."
                     "grade_fe Grade F.E."
                     "socioeconomic_controls Socioeconomic controls")
             title("Main Results")
             addnotes("Note: This table presents OLS regression estimates of the effect of \emph{eviction rate} on mathematics and reading"
                      "proficiency rates. Each column represents one regression. All regressions control for \emph{pct. white}, \emph{poverty rate},"
                    "\emph{pct. renter occupied}, \emph{median household income}, and \emph{median property value}. Robust standard errors"
                    "clustered at the city-level.");
#delimit cr


// *** diverse sample
local outcomes math read
summarize pctwhite, detail
scalar fiftieth_percentile = r(p50)
generate diverse = (pctwhite < fiftieth_percentile)
eststo clear
foreach var of varlist `outcomes' {
  // socioeconomic controls, no F.E.
  eststo: regress `var' evictionrate i.place_fips if diverse, cluster(place_fips)
  estadd local socioeconomic_controls "No"
  estadd local place_fe "Yes"
  estadd local year_fe "No"
  estadd local grade_fe "No"
  estadd scalar districts = e(N_clust)
  // socioeconomic controls, place FE
  eststo: regress `var' evictionrate i.place_fips i.year if diverse, cluster(place_fips)
  estadd local socioeconomic_controls "No"
  estadd local place_fe "Yes"
  estadd local year_fe "Yes"
  estadd local grade_fe "No"
  estadd scalar districts = e(N_clust)
  // socioeconomic controls, place FE, year FE
  eststo: regress `var' evictionrate i.place_fips i.year i.grade if diverse, cluster(place_fips)
  estadd local socioeconomic_controls "No"
  estadd local place_fe "Yes"
  estadd local year_fe "Yes"
  estadd local grade_fe "Yes"
  estadd scalar districts = e(N_clust)
  // socioeconomic controls, place FE, year FE, grade FE
  eststo: regress `var' evictionrate `controls_place_year_grade_fe' if diverse, cluster(place_fips)
  estadd local socioeconomic_controls "Yes"
  estadd local place_fe "Yes"
  estadd local year_fe "Yes"
  estadd local grade_fe "Yes"
  estadd scalar districts = e(N_clust)
}
#delimit ;
esttab using ${output_tables}/diverse_regressions.tex,
             `universal_tableopts'
             keep(evictionrate)
             mgroups("Pct. Proficient in Math" "Pct. Proficient in Reading", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
             nomtitles booktabs
             eqlabels(none)
             scalars("districts Number of clusters"
                     "r2 $\text{R}^2$"

                     "place_fe Place F.E."
                     "year_fe Year F.E."
                     "grade_fe Grade F.E."
                   "socioeconomic_controls Socioeconomic controls")
             title("Heterogeneous Treatment Effects in Diverse City-Years")
             addnotes("Note: This table presents OLS regression estimates of the effect of \emph{eviction rate} on mathematics and reading"
                      "proficiency rates. Regressions are identical to the previous table except that the sample has been restricted"
                    "to city-years with values of \emph{pct. white} below the 50th percentile.");
#delimit cr


// *** non-diverse sample
local outcomes math read
summarize pctwhite, detail
scalar fiftieth_percentile = r(p50)
// generate diverse = (pctwhite < fiftieth_percentile)
eststo clear
foreach var of varlist `outcomes' {
  // socioeconomic controls, no F.E.
  eststo: regress `var' evictionrate i.place_fips if !diverse, cluster(place_fips)
  estadd local socioeconomic_controls "No"
  estadd local place_fe "Yes"
  estadd local year_fe "No"
  estadd local grade_fe "No"
  estadd scalar districts = e(N_clust)
  // socioeconomic controls, place FE
  eststo: regress `var' evictionrate i.place_fips i.year if !diverse, cluster(place_fips)
  estadd local socioeconomic_controls "No"
  estadd local place_fe "Yes"
  estadd local year_fe "Yes"
  estadd local grade_fe "No"
  estadd scalar districts = e(N_clust)
  // socioeconomic controls, place FE, year FE
  eststo: regress `var' evictionrate i.place_fips i.year i.grade if !diverse, cluster(place_fips)
  estadd local socioeconomic_controls "No"
  estadd local place_fe "Yes"
  estadd local year_fe "Yes"
  estadd local grade_fe "Yes"
  estadd scalar districts = e(N_clust)
  // socioeconomic controls, place FE, year FE, grade FE
  eststo: regress `var' evictionrate `controls_place_year_grade_fe' if !diverse, cluster(place_fips)
  estadd local socioeconomic_controls "Yes"
  estadd local place_fe "Yes"
  estadd local year_fe "Yes"
  estadd local grade_fe "Yes"
  estadd scalar districts = e(N_clust)
}
#delimit ;
esttab using ${output_tables}/non_diverse_regressions.tex,
             `universal_tableopts'
             keep(evictionrate)
             mgroups("Pct. Proficient in Math" "Pct. Proficient in Reading", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
             nomtitles booktabs
             eqlabels(none)
             scalars("districts Number of clusters"
                     "r2 $\text{R}^2$"

                     "place_fe Place F.E."
                     "year_fe Year F.E."
                     "grade_fe Grade F.E."
                   "socioeconomic_controls Socioeconomic controls")
             title("Heterogeneous Treatment Effects in Non-Diverse City-Years")
             addnotes("Note: This table presents OLS regression estimates of the effect of \emph{eviction rate} on mathematics and reading"
                      "proficiency rates. Regressions are identical to the previous table except that the sample has been restricted"
                    "to city-years with values of \emph{pct. white} above the 50th percentile.");
#delimit cr
