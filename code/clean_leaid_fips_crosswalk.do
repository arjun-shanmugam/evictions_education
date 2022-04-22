/**********************************************************************/
/*
Evictions & Education | clean_crosswalk.do

Cleans NCES's LEA ID to FIPS place code crosswalk.
*/
/**********************************************************************/

#delimit ;
import excel ${leaid_fips_place_crosswalk}, sheet("grf19_lea_place")
                                            firstrow
                                            case(lower)
                                            allstring
                                            clear;
#delimit cr

drop if substr(place, 1, 2) != "39"  // drop non-Ohio schools

drop landarea waterarea  // drop unneeded variables

destring count, replace
rename count num_cities_spanned_by_district  // rename count variable appropriately

bysort place: generate city_group_number = _n
by place: egen num_districts_spanned_by_city = max(city_group_number)
drop city_group_number

/*
tabulate num_cities_spanned_by_district
      COUNT |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |         25        1.44        1.44
          2 |        146        8.42        9.86
          3 |        341       19.67       29.53
          4 |        336       19.38       48.90
          5 |        322       18.57       67.47
          6 |        207       11.94       79.41
          7 |        115        6.63       86.04
          8 |         72        4.15       90.20
          9 |         48        2.77       92.96
         10 |         36        2.08       95.04
         11 |         30        1.73       96.77
         12 |         11        0.63       97.40
         14 |         13        0.75       98.15
         16 |         15        0.87       99.02
         18 |         17        0.98      100.00
------------+-----------------------------------
      Total |      1,734      100.00


tabulate num_districts_spanned_by_city
num_distric |
ts_spanned_ |
    by_city |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        985       56.81       56.81
          2 |        364       20.99       77.80
          3 |        162        9.34       87.14
          4 |         88        5.07       92.21
          5 |         75        4.33       96.54
          6 |         12        0.69       97.23
          7 |         14        0.81       98.04
          8 |          8        0.46       98.50
         10 |         10        0.58       99.08
         16 |         16        0.92      100.00
------------+-----------------------------------
      Total |      1,734      100.00
*/
keep leaid place name_place19
rename place fips



save ${cleaned_data}/cleaned_leaid_fips_crosswalk.dta, replace
