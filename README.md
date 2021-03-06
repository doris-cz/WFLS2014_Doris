# WFLS2014_Doris

Doris Zhang, MSPP at NYU Wagner, July 2022

## About the research
This research aims to explore the potential influential factors of breastfeeding practice and inform potential policy changes that could support breastfeeding practice responsibly. This research uses the “New York City Work and Family Leave Survey (WFLS) 2014” dataset. 

## Data source
WFLS is a telephone survey conducted in March 2016 to understand the availability of paid family leave and its impacts on families. It randomly selected English and Spanish speaking adults who gave birth in New York City in 2014 and who were living with their child at the time of the survey. 

More information about the survey (including the dataset and the data dictionary) can be found on the NYC OpenData website: https://data.cityofnewyork.us/Health/New-York-City-Work-and-Family-Leave-Survey-WFLS-20/grnn-mvqe

Questionnaire of the WFLS survey can be found here: https://www1.nyc.gov/assets/doh/downloads/pdf/hca/paid-family-leave-final-questionnaire.pdf

The Paid Family Leave report developed by New York City Department of Health and Mental Hygiene based on the WFLS dataset can be found here: https://www1.nyc.gov/assets/doh/downloads/pdf/hca/paid-family-leave-report1.pdf

## Introduction to this folder
* Data: New_York_City_Work_and_Family_Leave_Survey__WFLS__2014.csv
* Data dictionary: WFLS_DataDictionary.xlsx
* Questionnaire: paid-family-leave-final-questionnaire.pdf
* Stata .do file: WFLS2014.do
* Draft: Barriers to Breastfeeding Practice Draft.pdf

## How to reproduce this analysis
 1) Download New_York_City_Work_and_Family_Leave_Survey__WFLS__2014.csv and WFLS2014.do into a local folder
 2) Open WFLS2014.do with Stata (_I ran this code on Stata 17_)
 3) Change the path of working directory into the address of your local folder which contains the .do file and the raw data (_The "cd" command in Line 6 in the .do file_)
 4) Run the .do file
