/**********************************************************************/
/*
Evictions & Education | clean_ohioid_leaid_crosswalk.do

Cleans Ohio District IRN to LEA district ID crosswalk.
*/
/**********************************************************************/


#delimit ;
// Note: must open the raw file and save as .xlsx before running code
import excel ${ohioid_leaid_crosswalk}, sheet("ncesdata_7C561E22")
                                        cellrange(A12:Q1049)
                                        firstrow
                                        allstring
                                        clear;
#delimit cr


split(StateDistrictID), parse("-")  // format: OH-######
rename NCESDistrictID leaid
rename StateDistrictID2 districtirn

keep leaid districtirn DistrictName Type

save ${cleaned_data}/cleaned_ohioid_leaid_crosswalk.dta, replace
