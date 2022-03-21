# climate_adaptation
# Written by Gyula Dörgő - Analysis of the CDP database queried on 20.05.2021 for Identifying the links between urban
climate hazards, mitigation and adaptation actions and
sustainability for future resilient cities
# MATLAB code
#Requires MES Toolbox (https://github.com/hhentschke/measures-of-effect-size-toolbox)
#Requires FP Growth (https://yarpiz.com/98/ypml116-fp-growth)
#This file describes the code and database. Please read the paper for more details on implications and the method's work principle.
 
#The github repository includes:
#Includes the CDP Database (in CDP20210520): 
#A main database that incorporates separate tables (with sheets as 01_Climate_Hazards, 02_Adaptation_Actions, 03_Emission_Reduction_Actions, 04_Emission_Reduction_Targets, 05_City-Wide_Emissions, 06_Cities_Percentage_EnergyMix, 07_Cities_Renewable_Energy_Targ, AccountNumbers)
# Account numbers connect each sheet/separate tables.
# KG_classes_new.xlsx provide the cities, their position and KG class. cobenefit_SDGs.xlsx is a table for encoding SDGs and cobenefits.
# CDP20210520/gas_separation.m - This script separates which greenhouse gas is admitted in the CDP database in a city (e.g. One city may only provide information on CO2 and CH4). This csript is only needed of a newer version of the database is being made. Requires the Gases Included column of city wide emissions.

# Codes
# merging_bittable.m - Analysis of climate hazards: Calculates the association (Cramér's V) of hazards, actions, KG classes and population, as well as encodes the data.
# FP_tree_.m _ Grows the frequent pattern tree based on the encoded data.
