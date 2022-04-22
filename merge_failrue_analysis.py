import pandas as pd
import numpy as np
merged_dataset = pd.read_stata("/Users/arjunshanmugam/Desktop/merge_failure_test.dta")
evictions_dataset = pd.read_stata("/Users/arjunshanmugam/Documents/GitHub/evictions_education/cleaned_data/cleaned_evictions_data.dta")

unmerged_tracts_from_master_observed_for_entire_sample_period = merged_dataset.loc[merged_dataset['num_years_tract_observed'] == 10]['tract_fips']
print(unmerged_tracts_from_master_observed_for_entire_sample_period.isin(evictions_dataset['tract_fips']).value_counts())

unmerged_tracts_from_master_observed_for_part_of_sample_period = merged_dataset.loc[merged_dataset['num_years_tract_observed'] < 10][['tract_fips', 'year']]
print(unmerged_tracts_from_master_observed_for_part_of_sample_period.isin(evictions_dataset[['tract_fips', 'year']]).value_counts())

combined = []
for i in range(len(unmerged_tracts_from_master_observed_for_part_of_sample_period)):
    combined.append((unmerged_tracts_from_master_observed_for_part_of_sample_period['tract_fips'].iloc[i],
    unmerged_tracts_from_master_observed_for_part_of_sample_period['year'].iloc[i]))

eviction = []
for i in range(len(evictions_dataset[['tract_fips', 'year']])):
    eviction.append((evictions_dataset['tract_fips'].iloc[i], evictions_dataset['year'].iloc[i]))

series1 = pd.Series(combined)
series2 = pd.Series(eviction)
print(series1)

print(series2)

print(series1.isin(series2).value_counts())
