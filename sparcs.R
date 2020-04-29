library(tidyverse)
library(RSocrata)
library(bnlearn)
library(ggplot2)

## function to download from socrata
sparcs_function <- function(url, year){
  # querying for conditions
  sparcs_720 <- read.socrata(paste(url,"?APR DRG Code=720", sep = ""))
  sparcs_194 <- read.socrata(paste(url,"?APR DRG Code=194", sep = ""))
  
  #rbind
  sparcs <- rbind(sparcs_720, sparcs_194)
  sparcs <- sparcs %>%
    filter(hospital_county %in% c("Manhattan", "Kings", "Bronx", "Queens", "Richmond")) %>%
    select(hospital_county, facility_name:length_of_stay,apr_drg_code:payment_typology_1,total_charges) %>%
    mutate(length_of_stay = as.numeric(length_of_stay),
           total_charges_day = round(total_charges/length_of_stay, 2),
           year = year) %>%
    filter(payment_typology_1 %in% c("Medicare", "Private Health Insurance", " Medicaid", "Blue Cross/Blue Shield", "Self-Pay"))
}

# load additional datasets
catchment_area <- read_csv("./data/nyc_hospitals_thiessen_polygons/hospitals_catchment_area.csv") %>%
  select(Hospital.N,System,area_sqmi)
hospital_beds <- read_csv("./data/nyc_hospitals/NYC_hospitals_data.csv") %>%
  select(`Hospital Name`, `Number of Beds`)
hospital_info <- inner_join(catchment_area, hospital_beds, by = c("Hospital.N" = "Hospital Name"))

# extract
sparcs_2017_NYC <- sparcs_function("https://health.data.ny.gov/resource/22g3-z7e7.csv", 2017)
sparcs_2016_NYC <- sparcs_function("https://health.data.ny.gov/resource/gnzp-ekau.csv", 2016)
sparcs_2015_NYC <- sparcs_function("https://health.data.ny.gov/resource/82xm-y6g8.csv", 2015)

# summarizing
sparcs_2017_NYC_summary <- sparcs_2017_NYC %>%
  drop_na() %>%
  group_by(apr_drg_code, facility_name, race, ethnicity, payment_typology_1, apr_severity_of_illness, age_group) %>%
  summarise(patients = n(),
            mean_length_of_stay = mean(length_of_stay),
            mean_total_charges_day = mean(total_charges_day)) 
sparcs_2017_NYC_summary <- inner_join(sparcs_2017_NYC_summary, hospital_info, by = c("facility_name" = "Hospital.N"))
sparcs_2016_NYC_summary <- sparcs_2016_NYC %>%
  drop_na() %>%
  group_by(apr_drg_code, facility_name, race, ethnicity, payment_typology_1, apr_severity_of_illness_description, age_group) %>%
  summarise(patients = n(),
            mean_length_of_stay = mean(length_of_stay),
            mean_total_charges_day = mean(total_charges_day)) 
sparcs_2016_NYC_summary <- inner_join(sparcs_2016_NYC_summary, hospital_info, by = c("facility_name" = "Hospital.N"))
sparcs_2015_NYC_summary <- sparcs_2015_NYC %>%
  drop_na() %>%
  group_by(apr_drg_code, facility_name, race, ethnicity, payment_typology_1, apr_severity_of_illness_description, age_group) %>%
  summarise(patients = n(),
            mean_length_of_stay = mean(length_of_stay),
            mean_total_charges_day = mean(total_charges_day))
sparcs_2015_NYC_summary <- inner_join(sparcs_2015_NYC_summary, hospital_info, by = c("facility_name" = "Hospital.N"))

# Septicemia
sparcs_2017_NYC_720_summary <- sparcs_2017_NYC_summary %>%
  filter(apr_drg_code == 720)
sparcs_2016_NYC_720_summary <- sparcs_2016_NYC_summary %>%
  filter(apr_drg_code == 720)
sparcs_2015_NYC_720_summary <- sparcs_2015_NYC_summary %>%
  filter(apr_drg_code == 720)

# Heart Failure
sparcs_2017_NYC_194_summary <- sparcs_2017_NYC_summary %>%
  filter(apr_drg_code == 194)
sparcs_2016_NYC_194_summary <- sparcs_2016_NYC_summary %>%
  filter(apr_drg_code == 194)
sparcs_2015_NYC_194_summary <- sparcs_2015_NYC_summary %>%
  filter(apr_drg_code == 194)


# writing to csv
write_csv(sparcs_2017_NYC_720_summary, "./data/sparcs/septicemia/summary_2017.csv")
write_csv(sparcs_2016_NYC_720_summary, "./data/sparcs/septicemia/summary_2016.csv")
write_csv(sparcs_2015_NYC_720_summary, "./data/sparcs/septicemia/summary_2015.csv")

write_csv(sparcs_2017_NYC_194_summary, "./data/sparcs/heart_failure/summary_2017.csv")
write_csv(sparcs_2016_NYC_194_summary, "./data/sparcs/heart_failure/summary_2016.csv")
write_csv(sparcs_2015_NYC_194_summary, "./data/sparcs/heart_failure/summary_2015.csv")

