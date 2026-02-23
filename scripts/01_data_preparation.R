# =============================================================================
# WELFARE STATE INSTITUTIONS AND DIGITALISATION PERCEPTIONS
# Cross-National Analysis Using OECD Risks That Matter 2024 Survey
# ===========
library(readxl)       # Read Excel files (.xlsx)
library(tidyverse)    # A collection: dplyr (data manipulation), ggplot2 (plots),tidyr (reshaping), readr (reading CSVs), etc.
library(countrycode)  # Converts between country name formats (e.g., "Germany" <-> "DEU")
library(corrplot)     # Visualise correlation matrices
library(ggrepel)      # Smart label placement on plots (avoids overlapping text)



# Data loading
rtm_raw <- read_excel(
  "/home/stefano/Documents/github-projects/oecd-ai-welfare-analysis/data-source/1-2024-RTM.xlsx",
  sheet = "g1.5",
  range = "F33:O60",       # Columns F (country names) through O (last variable) selection of the columns that matter to the analysis
  col_names = FALSE        # blank names so I can set custom names below
)


# namingthe columns with code referring to the specific questions (which are too descriptive and don't help operationalisation)
colnames(rtm_raw) <- c(
  "country",
  "threat_robot",         # My job will be replaced by a robot
  "threat_ai",            # My job will be taken over by AI like ChatGPT
  "threat_platform",      # Replaced by someone on an internet platform
  "threat_skills",        # Lose job because not good enough with new tech
  "threat_foreign",       # Job taken over by person from another country
  "threat_offshored",     # Job moved to a different country
  "opp_worklife",         # Tech will improve work-life balance
  "opp_physical",         # Tech will reduce physical demands
  "opp_mental"            # Tech will reduce mental demands / boredom
)




# Loading the institutional data (independent variables)

# Three sources:
#   A) EPL  — Employment Protection Legislation (how hard it is to fire someone)
#   B) SOCX — Social expenditure as % of GDP (how much the state spends on welfare)
#   C) ICTWSS — Union density (% of workers who are union members)
#
# These varaibles should depict each state's welfare context


# a) Employment Protection Legislation (EPL):
# Source: OECD Employment Protection Database, Version 4
# Scale: 0 to 6 (0 = least strict, 6 = most strict)
# Measure: "Individual and collective dismissals (regular contracts)"
# Available years: 2013-2019

epl_raw <- read_csv("/home/stefano/Documents/github-projects/oecd-ai-welfare-analysis/data-source/3-OECD-EPL.csv")

# The OECD data explorer format has many metadata columns. I only need three:
# REF_AREA (country ISO3 code), TIME_PERIOD (year), OBS_VALUE (the actual number)

epl <- epl_raw %>%
  select(iso3 = REF_AREA, year = TIME_PERIOD, epl = OBS_VALUE) %>%
  filter(iso3 != "OECD") %>%             # Remove the OECD average row
  group_by(iso3) %>%
  filter(year == max(year)) %>%          # Take the most recent year per country based on the idea that the most recent available value gives us the best approximation of the institutional environment at the time of the survey
  ungroup() %>%
  select(iso3, epl)


# b) Social Expenditure (SOCX):
# Source: OECD Social Expenditure Database
# Unit: Public social expenditure as % of GDP
# Available years: 2010-2024

socx_raw <- read_csv("/home/stefano/Documents/github-projects/oecd-ai-welfare-analysis/data-source/4-OECD_SOCX.csv")

socx <- socx_raw %>%
  select(iso3 = REF_AREA, year = TIME_PERIOD, socx = OBS_VALUE) %>%
  filter(iso3 != "OECD") %>%
  filter(year %in% c(2022, 2023)) %>%
  group_by(iso3) %>%
  # If both 2022 and 2023 exist, take 2022 (more stable, further from survey)
  filter(year == min(year)) %>%
  ungroup() %>%
  select(iso3, socx)

cat("\nSOCX data:", nrow(socx), "countries\n")
print(socx)


# c) Union Density (UD) from ICTWSS:
# Source: ICTWSS (Institutional Characteristics of Trade Unions, Wage Setting,
#         State Intervention and Social Pacts) database, version 2
# Unit: % of employees who are trade union members
# Available years: varies wildly by country (some up to 2024, some stop in 1980s)

ictwss_raw <- read_csv("/home/stefano/Documents/github-projects/oecd-ai-welfare-analysis/data-source/2-ICTWSS.csv")


ud <- ictwss_raw %>%
  select(country, iso3, year, UD = UD) %>%
  filter(!is.na(UD), UD != -99, UD != "") %>%       # Remove missing/coded values
  mutate(
    UD = as.numeric(UD),
    year = as.integer(year)
  ) %>%
  group_by(iso3) %>%
  filter(year == max(year)) %>%                       # Most recent per country
  ungroup() %>%
  mutate(ud_data_old = year < 2014) %>%               # Flag old data
  select(iso3, ud = UD, ud_year = year, ud_data_old)

cat("\nUnion Density data:", nrow(ud), "countries\n")
cat("Countries with old data (before 2014):\n")
print(filter(ud, ud_data_old))


# =============================================================================
# STEP 3: HARMONISE COUNTRY IDENTIFIERS AND MERGE
# =============================================================================
# This is the unglamorous heart of empirical research: making datasets talk
# to each other. Our RTM data uses full names ("United States"), the OECD data
# uses ISO3 codes ("USA"), and the ICTWSS uses a mix.
#
# The countrycode package handles most conversions. We'll convert RTM country
# names to ISO3 codes, then merge everything on ISO3.

# First, let's add ISO3 codes to the RTM data
rtm <- rtm_raw %>%
  mutate(iso3 = countrycode(country, origin = "country.name", destination = "iso3c"))

# Check: did all countries convert correctly?
cat("\nRTM country name to ISO3 conversion:\n")
print(select(rtm, country, iso3))

# MANUAL FIXES if needed:
# "Türkiye" might not convert automatically
rtm <- rtm %>%
  mutate(iso3 = case_when(
    country == "Türkiye" ~ "TUR",
    country == "Korea"   ~ "KOR",
    TRUE ~ iso3
  ))

# Also fix ICTWSS ISO3 codes that might differ
ud <- ud %>%
  mutate(iso3 = case_when(
    iso3 == "GBR" ~ "GBR",  # should be fine
    TRUE ~ iso3
  ))

# now join all four datasets by ISO3 code.

merged <- rtm %>%
  left_join(epl, by = "iso3") %>%
  left_join(socx, by = "iso3") %>%
  left_join(ud, by = "iso3")

# fixing non numeric formats and filtering out all the null values
merged <- filter(merged, !is.na(country))
merged <- merged %>% mutate(across(all_of(rtm_vars), as.numeric))


# Check what we got
cat("\n====================================\n")
cat("MERGED DATASET SUMMARY\n")
cat("====================================\n")
cat("Total countries:", nrow(merged), "\n")
cat("\nMissing data per variable:\n")
merged %>%
  summarise(
    epl_missing  = sum(is.na(epl)),
    socx_missing = sum(is.na(socx)),
    ud_missing   = sum(is.na(ud))
  ) %>%
  print()

cat("\nCountries with missing EPL:\n")
print(filter(merged, is.na(epl))$country)

cat("\nCountries with missing SOCX:\n")
print(filter(merged, is.na(socx))$country)

cat("\nCountries with missing UD:\n")
print(filter(merged, is.na(ud))$country)

cat("\nCountries with old UD data:\n")
print(filter(merged, ud_data_old == TRUE) %>% select(country, ud, ud_year))

# save to file for analysis in the next script

write_csv(merged, "/home/stefano/Documents/github-projects/oecd-ai-welfare-analysis/data-source/merged_data.csv")

cat("\n✓ Merged dataset saved to data/merged_data.csv\n")
cat("\nFull merged dataset:\n")
print(merged %>% select(country, iso3, threat_robot, threat_ai, opp_worklife, epl, socx, ud))
