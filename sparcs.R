library(tidyverse)
library(RSocrata)
library(bnlearn)
library(ggplot2)

sparcs_2017 <- read.socrata("https://health.data.ny.gov/resource/22g3-z7e7.csv?APR DRG Code=720")
sparcs_2017_NYC <- sparcs_2017 %>%
  filter(hospital_county %in% c("Manhattan", "Kings", "Queens", "Bronx", "Richmond"))
sparcs_2017_NYC_720 <- sparcs_2017_NYC %>%
  select(hospital_county, facility_name:patient_disposition,payment_typology_1,total_charges:total_costs) %>%
  mutate(length_of_stay = as.numeric(length_of_stay),
         race = ifelse(ethnicity == "Spanish/Hispanic", "Spanish/Hispanic", race),
         total_charges_day = round(total_charges/length_of_stay, 2),
         total_costs_day = round(total_costs/length_of_stay, 2))
sparcs_2017_NYC_720_summary <- sparcs_2017_NYC_720 %>%
  group_by(facility_name, race, payment_typology_1) %>%
  summarise(number_patients = n(),
            mean_length_of_stay = mean(length_of_stay),
            mean_total_costs_day = mean(total_costs_day),
            mean_total_charges_day = mean(total_charges_day))
sparcs_2017_NYC_720_summary_payment <- sparcs_2017_NYC_720 %>%
  group_by(facility_name, payment_typology_1) %>%
  summarise(number_patients = n(),
            mean_length_of_stay = mean(length_of_stay),
            mean_total_costs_day = mean(total_costs_day),
            mean_total_charges_day = mean(total_charges_day))
sparcs_2017_NYC_720_summary_race <- sparcs_2017_NYC_720 %>%
  group_by(facility_name, race) %>%
  summarise(number_patients = n(),
            mean_length_of_stay = mean(length_of_stay),
            mean_total_costs_day = mean(total_costs_day),
            mean_total_charges_day = mean(total_charges_day))

ggplot(sparcs_2017_NYC_720_summary_race, aes(x = facility_name, y = number_patients)) +
  geom_point(aes(color = race)) + 
  coord_flip()
