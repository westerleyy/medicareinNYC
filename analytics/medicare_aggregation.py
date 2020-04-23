# -*- coding: utf-8 -*-
"""
Created on Thu Apr 23 15:19:52 2020

@author: wesch
"""
# importing modules

import numpy as np
import pandas as pd
import os

# change directory 
os.chdir('C:\\Users\\wesch\\OneDrive\\Documents\\RStudio\\medicareinNYC')

# creating paths 

data_path = "./data/"
census_tracts = "census_tracts/"

# loading file 

hospitals_and_income = pd.read_csv(data_path+census_tracts+"censustracts_hospitals_thiessen_income.csv")
hospitals_and_race = pd.read_csv(data_path+census_tracts+"censustracts_hospitals_thiessen_race.csv")

# grouping 

###income
## grouping independent hospitals by their name first
independent_hospitals_and_income = hospitals_and_income[hospitals_and_income["System"]=="Others"]
independent_hospitals_and_income = independent_hospitals_and_income.iloc[:,np.r_[12:25]]
independent_hospitals_and_income_grouped = independent_hospitals_and_income.groupby(["Hospital N"]).mean()

## in-system hospitals
hospitals_and_income_grouped = hospitals_and_income.iloc[:,np.r_[12:24, 26]]
system_hospitals_and_income = hospitals_and_income_grouped[hospitals_and_income_grouped["System"]!="Others"]
hospitals_and_income_grouped = system_hospitals_and_income.groupby(["System"]).mean()

## concatenating them together
grouped_hospitals_and_income = pd.concat([hospitals_and_income_grouped, independent_hospitals_and_income_grouped])


### race
## grouping independent hospitals by their name first
independent_hospitals_and_race = hospitals_and_race[hospitals_and_race["System"]=="Others"]
independent_hospitals_and_race = independent_hospitals_and_race.iloc[:,np.r_[12:21]]
independent_hospitals_and_race_grouped = independent_hospitals_and_race.groupby(["Hospital N"]).sum()

## in-system hospitals
hospitals_and_race_grouped = hospitals_and_race.iloc[:,np.r_[12:20, 22]]
system_hospitals_and_race = hospitals_and_race_grouped[hospitals_and_race_grouped["System"]!="Others"]
hospitals_and_race_grouped = system_hospitals_and_race.groupby(["System"]).sum()

## concatenating them together
grouped_hospitals_and_race = pd.concat([hospitals_and_race_grouped, independent_hospitals_and_race_grouped])

# counting number of beds
num_beds = hospitals_and_race.loc[:,["System", "Hospital N", "Number of"]]
num_beds = num_beds.drop_duplicates()
num_beds_system = num_beds[num_beds["System"]!="Others"], 
num_beds_system = num_beds_system.loc[:, ["System", "Number of"]]
num_beds_system = num_beds_system.groupby(["System"]).sum()
num_beds_others = num_beds[num_beds["System"]=="Others"]
num_beds_others = num_beds_others.loc[:, ["Hospital N", "Number of"]]
num_beds_others = num_beds_others.rename(columns = {"Hospital N":"System"})
num_beds_others = num_beds_others.set_index("System")
num_beds = pd.concat([num_beds_system, num_beds_others])

# inner join
grouped_hospitals_and_race = pd.merge(grouped_hospitals_and_race, num_beds, left_index = True, right_index = True)

# exporting as CSV
grouped_hospitals_and_race.to_csv(data_path+census_tracts+"hospitals_race.csv")
grouped_hospitals_and_income.to_csv(data_path+census_tracts+"hospitals_income.csv")
