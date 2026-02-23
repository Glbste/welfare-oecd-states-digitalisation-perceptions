
# SETUP

packages <- c(
  "readxl",       # Read Excel files
  "tidyverse",    # dplyr, ggplot2, tidyr, readr, purrr, stringr, forcats, tibble
  "countrycode",  # Convert between country name formats
  "corrplot",     # Correlation matrix visualisation
  "ggrepel",      # Non-overlapping text labels on plots
  "broom",        # Tidy model outputs
  "patchwork"     # Combine multiple ggplots into one figure
)

install.packages(packages, repos = "https://cran.r-project.org")

