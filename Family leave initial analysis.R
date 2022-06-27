# We take an initial look at the family leave respon

library(tidyverse)
library(janitor)
library(naniar) # use this package to replace the value 77 and 99 (codes for "don't know" and "refuse to answer" responses) with a missing value

wfls14_raw <- read_csv("New_York_City_Work_and_Family_Leave_Survey__WFLS__2014.csv", header=TRUE)

family_leave_data <- wfls14_raw %>% 
  select(el11, el12_1, el12wks, el12mns, el13a, el13b, el13c, el13d, el13e, el14) %>%
  filter(el11 == 1 | el11 == 2 | el11 == 3 ) %>%
  filter(el12_1 == 2 | el12_1 == 3) %>%
  replace_with_na(replace = list(el13a = c(77,99),el13b = c(77,99),el13c = c(77,99),el13d = c(77,99),el13e = c(77,99))) %>%
  rowwise() %>%
  mutate(total_month_wks = sum(el12wks,4*el12mns,na.rm = TRUE),
         total_paid_wks = sum(el13a,el13b,el13c,el13e,na.rm = TRUE),
         row_to_keep = !(el11 != 2 & total_paid_wks == 0)) %>%
  filter(row_to_keep == TRUE)

family_leave_data_sum <- family_leave_data %>% 
  group_by(el11) %>% 
  summarize(number = n(),
            median_total_wks = median(total_month_wks),
            median_paid_wks = median(total_paid_wks))

write.csv(family_leave_data_sum,"family_leave_initial_summary.csv")
