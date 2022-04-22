/**********************************************************************/
/*
Evictions & Education | clean_leaid_tract_crosswalk.do

Cleans NCES's LEA ID to census tract fips code crosswalk.
*/
/**********************************************************************/

#delimit ;
import excel ${leaid_tract_crosswalk}, sheet("grf19_lea_tract")
                                            firstrow
                                            case(lower)
                                            allstring
                                            clear;
#delimit cr


drop if substr(tract, 1, 2) != "39"  // drop non-Ohio rows

drop landarea waterarea  // drop unneeded variables

destring count, replace
rename count num_tracts_spanned_by_district  // rename count variable

// deal with tracts that span multiple districts
bysort tract: generate tract_num_within_group = _n
by tract: egen num_districts_spanned_by_tract = max(tract_num_within_group)
drop tract_num_within_group

// overview of districts that span more than one tract
tab num_tracts_spanned_by_district
/*
tab num_tracts_spanned_by_district

      COUNT |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |         11        0.21        0.21
          2 |         54        1.01        1.22
          3 |        207        3.88        5.10
          4 |        276        5.18       10.28
          5 |        390        7.32       17.60
          6 |        408        7.65       25.25
          7 |        483        9.06       34.32
          8 |        352        6.60       40.92
          9 |        261        4.90       45.82
         10 |        200        3.75       49.57
         11 |        264        4.95       54.52
         12 |        252        4.73       59.25
         13 |        143        2.68       61.93
         14 |        154        2.89       64.82
         15 |        165        3.10       67.92
         16 |        112        2.10       70.02
         17 |         68        1.28       71.29
         18 |         90        1.69       72.98
         19 |         57        1.07       74.05
         20 |        100        1.88       75.93
         21 |         63        1.18       77.11
         22 |         22        0.41       77.52
         23 |         69        1.29       78.82
         24 |         24        0.45       79.27
         25 |         50        0.94       80.21
         26 |         26        0.49       80.69
         27 |         54        1.01       81.71
         29 |         58        1.09       82.80
         32 |         32        0.60       83.40
         35 |         35        0.66       84.05
         36 |         36        0.68       84.73
         45 |         45        0.84       85.57
         65 |         65        1.22       86.79
         68 |         68        1.28       88.07
        108 |        108        2.03       90.09
        133 |        133        2.50       92.59
        170 |        170        3.19       95.78
        225 |        225        4.22      100.00
------------+-----------------------------------
      Total |      5,330      100.00

*/

// overview of tracts that span more than one district
tab num_districts_spanned_by_tract
/*

num_distric |
ts_spanned_ |
   by_tract |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,807       33.90       33.90
          2 |      1,640       30.77       64.67
          3 |      1,008       18.91       83.58
          4 |        568       10.66       94.24
          5 |        205        3.85       98.09
          6 |         66        1.24       99.32
          7 |         28        0.53       99.85
          8 |          8        0.15      100.00
------------+-----------------------------------
      Total |      5,330      100.00
*/

// drop all variables except those used for crosswalk
keep leaid tract
rename tract tract_fips


save ${cleaned_data}/cleaned_leaid_tract_crosswalk.dta, replace
