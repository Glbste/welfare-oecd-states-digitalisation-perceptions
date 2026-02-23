
# BIVARIATE CORRELATION


library(tidyverse)
library(corrplot)
library(ggrepel)
library(broom)

# Load the merged data
merged <- read_csv("/data-source/merged_data.csv")


# Drop entries that are missing one or more information 
complete_cases <- merged %>%
  filter(!is.na(epl), !is.na(socx), !is.na(ud))

cat("Countries with complete institutional data:", nrow(complete_cases), "out of", nrow(merged), "\n")
cat("Dropped countries:\n")
print(setdiff(merged$country, complete_cases$country))

# Pulling list of variables for the correlation test to have references  
rtm_vars <- c("threat_robot", "threat_ai", "threat_platform", "threat_skills",
               "threat_foreign", "threat_offshored",
               "opp_worklife", "opp_physical", "opp_mental")

inst_vars <- c("epl", "socx", "ud")


# Create an empty data frame to store results
cor_results <- data.frame(
  rtm_var = character(),
  inst_var = character(),
  r = numeric(),
  p_value = numeric(),
  n = numeric(),
  sig = character()
)

# Loop through every combination of RTM item and institutional variable
for (rv in rtm_vars) {
  for (iv in inst_vars) {
    
    # Run the correlation test for this pair
    test <- cor.test(
      merged[[rv]],
      merged[[iv]],
      use = "pairwise.complete.obs",
      method = "pearson"
    )
    
    # Extract the results
    r <- test$estimate
    p <- test$p.value
    n <- test$parameter + 2
    
    # Assign significance stars
    if (p < 0.001) {
      sig <- "***"
    } else if (p < 0.01) {
      sig <- "**"
    } else if (p < 0.05) {
      sig <- "*"
    } else if (p < 0.10) {
      sig <- "."
    } else {
      sig <- ""
    }
    
    # Add this result as a new row
    cor_results <- rbind(cor_results, data.frame(
      rtm_var = rv,
      inst_var = iv,
      r = r,
      p_value = p,
      n = n,
      sig = sig
    ))
  }
}

# Print in a readable format
cat("BIVARIATE CORRELATIONS: RTM items × Institutional variables\n")

cor_wide <- cor_results %>%
  select(rtm_var, inst_var, r_sig = r, sig) %>%
  mutate(display = paste0(round(r_sig, 3), sig)) %>%
  select(rtm_var, inst_var, display) %>%
  pivot_wider(names_from = inst_var, values_from = display)

write_csv(cor_results, "/output/correlation_results.csv")

print(cor_wide, n = Inf)

cat("\nSignificance: *** p<0.001, ** p<0.01, * p<0.05, . p<0.10\n")
cat("N varies per pair due to missing institutional data\n")


# Find the strongest absolute correlation
strongest <- cor_results %>%
  arrange(desc(abs(r))) %>%
  slice(1)

cat("\nStrongest correlation:", strongest$rtm_var, "×", strongest$inst_var,
    "r =", round(strongest$r, 3), "p =", round(strongest$p_value, 4), "\n")


# Scatterplot
p1 <- ggplot(merged, aes(x = .data[[strongest$inst_var]],
                          y = .data[[strongest$rtm_var]])) +
  geom_point(size = 3, alpha = 0.7) +
  geom_text_repel(aes(label = country), size = 3, max.overlaps = 15) +
  geom_smooth(method = "lm", se = TRUE, color = "steelblue", alpha = 0.2) +
  labs(
    title = paste0("Strongest bivariate relationship (r = ", round(strongest$r, 3), ")"),
    x = strongest$inst_var,
    y = strongest$rtm_var,
    caption = paste0("N = ", strongest$n, " countries. Grey band = 95% confidence interval.")
  ) +
  theme_minimal(base_size = 13)

ggsave("/output/plot_strongest_bivariate.png", p1, width = 10, height = 7, dpi = 150)
cat("\n✓ Saved: output/plot_strongest_bivariate.png\n")


# Comparative plot

plots_strongest_inst_compare <- map(inst_vars, function(iv) {
  r_val <- cor_results %>% filter(rtm_var == "opp_worklife", inst_var == iv) %>% pull(r)
  p_val <- cor_results %>% filter(rtm_var == "opp_worklife", inst_var == iv) %>% pull(p_value)

  ggplot(merged, aes(x = .data[[iv]], y = threat_robot)) +
    geom_point(size = 2.5) +
    geom_text_repel(aes(label = country), size = 2.5, max.overlaps = 10) +
    geom_smooth(method = "lm", se = TRUE, color = "steelblue", alpha = 0.2) +
    labs(
      title = paste0(iv, " (r = ", round(r_val, 2), ", p = ", round(p_val, 3), ")"),
      x = iv,
      y = "% expect life opp from tech advancements"
    ) +
    theme_minimal(base_size = 11)
})

# Combine into one figure
library(patchwork)

p_combined <- plots_strongest_inst_compare[[1]] + plots_strongest_inst_compare[[2]] + plots_strongest_inst_compare[[3]] +
  plot_annotation(
    title = "Work Life Opportunities vs. Welfare State Institutions",
    subtitle = "Each point = one country. Line = OLS fit with 95% CI."
  )

ggsave("/output//plot_threat_robot_vs_institutions.png", p_combined, width = 15, height = 5, dpi = 150)
cat("✓ Saved: output/plot_worklife_balance_vs_institutions.png\n")
