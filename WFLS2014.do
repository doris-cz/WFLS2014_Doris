set more off
capture log close
clear
cap clear matrix

cd "D:\Doris\NYU Wagner\Courses\Policy and Data Studio\WFLS2014_Stata" // Please change the path as needed
log using "WFLS2014.log", replace

import delimited "New_York_City_Work_and_Family_Leave_Survey__WFLS__2014.csv", clear
svyset [pweight=pop_weight] 
//gen int_weight = int(pop_weight) // Frequency weight

/*** Breastfeeding data ***/

gen excl_bf = . // Continuous - duration of exclusive breastfeeding (in weeks)
	replace excl_bf = 0 if bf1_1 == 1 // Never breasfed
	replace excl_bf = 0.5 if bf1a_1 == 1 // Less than a week
	replace excl_bf = bf1awks if bf1a_1 == 2
	replace excl_bf = bf1amns*4 if bf1a_1 == 3
// Invalid answers (no answer or "I don't know) are treated as missing value

gen excl_bf_type = . // Categorical
	replace excl_bf_type = 0 if excl_bf == 0 // Never
	replace excl_bf_type = 1 if excl_bf>0 & excl_bf<=4 // <= 1 month
	replace excl_bf_type = 2 if excl_bf>4 & excl_bf<=12 // 1-3 months
	replace excl_bf_type = 3 if excl_bf>12 & excl_bf<=24 // 3-6 months
	replace excl_bf_type = 4 if excl_bf>24 & excl_bf<=36 // 6-9 months
	replace excl_bf_type = 5 if excl_bf>36 & excl_bf!=. // >= 9 months
label define excl_bf_type_lab ///
	0 "Never Breastfed" 1 "≤ 1 month" 2 "1-3 months" 3 "3-6 months" 4 "6-9 months" 5 "≥ 9 months"  
label values excl_bf_type excl_bf_type_lab

graph hbar (percent) [pweight=pop_weight], over(excl_bf_type, label(labsize(small))) ///
	title("Figure 1. Distribution of Exclusive Breastfeeding Duration (%)", span size(medium)) ///
	subtitle("1039 Respondents", size(small) span) ///
	graphregion(color(white)) ///
	blabel(bar, position(center) format(%12.2fc) color(white) size(small)) ///
	ylabel(, nogrid) yscale(off)
gr export exclusive_breastfeeding_distribution.png, replace as(png)

gen byte excl_bf_3m = (excl_bf>=12 & excl_bf!=.) // Dummy for 3-month duration
	replace excl_bf_3m = . if excl_bf == .
label define excl_bf_3m_lab 0 "No" 1 "Yes"
label values excl_bf_3m excl_bf_3m_lab

gen byte excl_bf_6m = (excl_bf>=24 & excl_bf!=.) // Dummy for 6-month duration
	replace excl_bf_6m = . if excl_bf == .
label define excl_bf_6m_lab 0 "No" 1 "Yes"
label values excl_bf_6m excl_bf_6m_lab

svy: mean excl_bf_3m excl_bf_6m

graph pie [pweight=pop_weight], over(excl_bf_3m) ///
	title("") subtitle("≥ 3 months", size(medium) span margin(large)) ///
	graphregion(color(white)) plotregion(margin(large)) ///
	legend(order(2 1) size(small) region(style(none))) ///
	plabel(2 percent, color(white) size(medium)) ///
	saving(3m, replace)
	
graph pie [pweight=pop_weight], over(excl_bf_6m) ///
	title("") subtitle("≥ 6 months", size(medium) span margin(large)) ///
	graphregion(color(white)) plotregion(margin(large)) ///
	plabel(2 percent, color(white) size(medium)) ///
	saving(6m, replace)
	
grc1leg 3m.gph 6m.gph, ///
	title("Figure 2. Duration of Exclusive Breastfeeding", span size(medium)) ///
	subtitle("1039 Respondents", size(small) span) ///
	legendfrom(3m.gph) position(6) span ///
	graphregion(color(white)) 
gr export exclusive_breastfeeding_pie.png, replace as(png)

/* Use -grc1leg- written by Vince Wiggins. 
Type in Stata command line -findit grc1leg- 
Click the link (grc1leg from http://www.stata.com/users/vwiggins) for installation */


/*** Who are more likely to breasefeed for a longer time? ***/

// 1. Reasons for stopping breastfeeding or pumping 
// Among those who gave valid answers and had stopped breastfeeding by the time of survey

replace bf2 = . if bf2 == 77
replace bf2 = 7 if bf2 == 6
label define bf2_lab 1 "I was not producing enough milk" 2 "It was too time consuming" ///
	3 "It was the right time to stop" 4 "I had to stop for medical reasons" ///
	5 "I went back to work" 7 "Other"
label values bf2 bf2_lab

graph hbar (percent) [pweight=pop_weight], over(bf2, label(labsize(small))) ///
	title("Figure 3. Main Reasons For Stopping Breastfeeding (%)", size(medium) span) ///
	subtitle("863 Respondents", size(small) span) ///
	graphregion(color(white)) ///
	blabel(bar, position(center) format(%12.2fc) color(white) size(small)) ///
	ylabel(, nogrid) yscale(off)
gr export reasons_stop.png, replace as(png)

tab excl_bf bf2 if bf2==1, missing


// 2. Previous child birth experiences

gen byte experience = (mp1>0)
label define experience_lab 0 "No" 1 "Yes"
label values experience experience_lab
graph hbar (mean) excl_bf [pweight=pop_weight], over(experience, gap(*2) label(labsize(small))) ///
	title("Figure 4. Duration of Exclusive Breastfeeding" "by Previous Childbirth Experience (wks)", size(medium) span) ///
	subtitle("1039 Respondents", size(small) span) ///
	graphregion(color(white)) ///
	outergap(*3) ///
	blabel(bar, position(center) format(%12.2fc) color(white) size(small)) ///
	ylabel(, nogrid) yscale(off)
gr export experience_wks.png, replace as(png)

svy: mean excl_bf, over(experience)
svy: mean excl_bf_3m, over(experience) //ADD PIE CHARTS
svy: mean excl_bf_6m, over(experience)
	
	
// 3. Duration of leave taken after childbirth (in weeks)
// Among working mothers who returned to work after childbirth, and gave a valid answer

gen leave = .
	replace leave = 0 if el11 ==4 // No leave
	replace leave = 0.5 if el12_1 == 1 // Less than a week
	replace leave = el12wks if el12_1 == 2
	replace leave = el12mns*4 if el12_1 == 3
	replace leave = . if el15==2 | el15==3 | el15==77

gen byte leave_3m = (leave>=12 & leave!=.) // Dummy for 3-month leave
	replace leave_3m = . if leave == .
label define leave_3m_lab 0 "No" 1 "Yes"
label values leave_3m leave_3m_lab
gen byte leave_6m = (leave>=24 & leave!=.) // Dummy for 6-month leave
	replace leave_6m = . if leave == .
label define leave_6m_lab 0 "No" 1 "Yes"
label values leave_6m leave_6m_lab

graph pie [pweight=pop_weight], over(leave_3m) ///
	title("") subtitle("≥ 3 months", size(medium) span margin(large)) ///
	graphregion(color(white)) plotregion(margin(large)) ///
	legend(order(2 1) size(small) region(style(none))) ///
	plabel(2 percent, color(white) size(medium)) ///
	saving(leave_3m, replace)
	
graph pie [pweight=pop_weight], over(leave_6m) ///
	title("") subtitle("≥ 6 months", size(medium) span margin(large)) ///
	graphregion(color(white)) plotregion(margin(large)) ///
	plabel(2 percent, color(white) size(medium)) ///
	saving(leave_6m, replace)
	
grc1leg leave_3m.gph leave_6m.gph, ///
	title("Figure 5. Duration of Leave Taken after Childbirth", span size(medium)) ///
	subtitle("630 Respondents", size(small) span) ///
	legendfrom(leave_3m.gph) position(6) span ///
	graphregion(color(white)) 
gr export leave_pie.png, replace as(png)

//How did you feel about the amount of time you were able to take off after the childbirth?
replace el14 = . if el14==77 | el14==99 | el15==2 | el15==3 | el15==77
label define el14_lab 1 "Too little" 2 "Just the right amount" 3 "Too much"
label values el14 el14_lab

graph pie [pweight=pop_weight], over(el14) ///
	title("Figure 6. How did you feel about the amount of time" "you were able to take off?", size(medium) span) ///
	subtitle("579 Respondents", size(small) span) ///
	plotregion(margin(large)) ///
	graphregion(color(white)) ///
	plabel(1 percent, color(white) size(small)) ///
	legend(size(small) rows(1) region(style(none)))
gr export feeling_leave.png, replace as(png)	

// Time off and breastfeeding duration	
svy: mean excl_bf_3m, over(leave_3m)
svy: mean excl_bf_3m, over(leave_6m)

graph bar (mean) excl_bf_3m [pweight=pop_weight], over(leave_3m, gap(*2) relabel(1 "< 3 months" 2 "≥ 3 months") label(labsize(medium))) ///
	graphregion(color(white)) ///
	outergap(*3) ///
	blabel(bar, position(center) format(%12.2fc) color(white) size(medium)) ///
	ylabel(, nogrid) yscale(off) ///
	saving(3mbr_3mleave, replace)
	
graph bar (mean) excl_bf_3m [pweight=pop_weight], over(leave_6m, gap(*2) relabel(1 "< 6 months" 2 "≥ 6 months") label(labsize(medium))) ///
	graphregion(color(white)) ///
	outergap(*3) ///
	blabel(bar, position(center) format(%12.2fc) color(white) size(medium)) ///
	ylabel(, nogrid) yscale(off) ///
	saving(3mbr_6mleave, replace)
	
graph combine 3mbr_3mleave.gph 3mbr_6mleave.gph, ///
	title("Figure 7. Possibility of Breastfeeding for at least 3 months" "by Duration of Leave", span size(medium)) ///
	subtitle("623 Respondents", size(small) span) ///
	graphregion(color(white)) 
gr export leave_breastfeeding.png, replace as(png)


// 4. Cultural background: race and ethnicity
replace d3= . if d3==77 | d3==99 // Hispanic or not
label define hispanic 1 "Hispanic" 2 "Non-Hispanic"
label values d3 hispanic
svy: mean excl_bf, over(d3)

graph hbar (mean) excl_bf [pweight=pop_weight], over(d3, gap(*4) label(labsize(medium))) ///
	subtitle("1060 Respondents", size(medium) span margin(large)) ///
	graphregion(color(white)) ///
	outergap(*4) ///
	blabel(bar, position(center) format(%12.2fc) color(white) size(medium)) ///
	ylabel(, nogrid) yscale(off) ///
	saving(hispanic, replace)

replace d4_1= . if d4_1==8 | d4_1==77 | d4_1==99 //Race
label define race 1 "White" 2 "African American" 3 "Asian" 4 "Native Hawaiian or Other Pacific Islander" 5 "American Indian or Alaska Native"
label values d4_1 race
svy: mean excl_bf, over(d4_1)

graph hbar (mean) excl_bf [pweight=pop_weight], ///
	over(d4_1, relabel(2 `" "African" "American" "' 4 `" "Native Hawaiian" "or Other" "Pacific Islander" "' 5 `" "American Indian" "or Alaska Native" "') label(labsize(medium))) ///
	subtitle("837 Respondents", size(medium) span margin(large)) ///
	graphregion(color(white)) ///
	outergap(*3) ///
	blabel(bar, position(center) format(%12.2fc) color(white) size(medium)) ///
	ylabel(, nogrid) yscale(off) ///
	saving(race, replace)

graph combine hispanic.gph race.gph, ///
	title("Figure 8. Duration of Exclusive Breastfeeding" "by Races and Ethnicities (wks)", span size(medium)) ///
	graphregion(color(white)) 
gr export race_ethnicity_breastfeeding.png, replace as(png)
	
//Allow for multiple answers - 15 respondents
replace d4_2= . if d4_2==8 | d4_2==77 | d4_2==99 
svy: mean excl_bf if d4_1==1 | d4_2==1
svy: mean excl_bf if d4_1==2 | d4_2==2
svy: mean excl_bf if d4_1==3 | d4_2==3
svy: mean excl_bf if d4_1==4 | d4_2==4
svy: mean excl_bf if d4_1==5 | d4_2==5


capture log close 