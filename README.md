# Welfare State Institutions and Digitalisation Perceptions

A cross-national analysis of how welfare state institutions shape citizens' perceptions of digitalisation, using the 2024 OECD Risks That Matter survey.

## Research Question

Do the institutional characteristics of a country's welfare state — social spending, employment protection, and labour organisation — predict how citizens perceive the impact of digitalisation on their working lives?

This question is motivated by comparative welfare state research (Esping-Andersen, 1990) and the growing literature on how institutional contexts mediate the social impact of AI and automation. If institutions matter, the same technology should provoke different responses depending on a country's welfare regime.

## Data

| File | Source | Description |
|------|--------|-------------|
| `1-2024-RTM.xlsx` | [OECD Risks That Matter 2024](https://www.oecd.org/en/about/programmes/oecd-risks-that-matter-rtm-survey.html) | Digitalisation perceptions: 9 survey items across 27 countries |
| `2-ICTWSS.csv` | [ICTWSS Database v2]([https://www.oecd.org/en/data/datasets/ictwss-database.html](https://www.oecd.org/en/data/datasets/oecdaias-ictwss-database.html)) | Union density (% of employees who are trade union members) |
| `3-OECD-EPL.csv` | [OECD Employment Protection Database](https://www.oecd.org/en/data/datasets/oecd-indicators-of-employment-protection.html) | Employment Protection Legislation index (0–6 scale, Version 4) |
| `4-OECD_SOCX.csv` | [OECD Social Expenditure Database](https://www.oecd.org/en/data/datasets/social-expenditure-database-socx.html) | Public social expenditure as % of GDP |

The dependent variables are split into two conceptual groups:
- **Threat perceptions** (6 items): job replaced by robot, AI, platform worker, foreign worker; job offshored; skills obsolescence
- **Opportunity perceptions** (3 items): technology improving work-life balance, reducing physical demands, reducing mental demands

## Preliminary Findings

Bivariate correlations (Pearson, N = 27 countries) reveal an asymmetric pattern across the three institutional dimensions:

- **Social expenditure (SOCX)** is the strongest predictor, negatively correlated with both threat and opportunity perceptions. The strongest relationship is with work-life balance optimism (r = −0.551, p = 0.003). Countries with higher social spending are less likely to see technology as either a threat or a benefit
- **Union density (UD)** selectively predicts threat perceptions, with the strongest relationship for foreign worker displacement (r = −0.529, p = 0.005). 
- **Employment protection (EPL)** shows no significant relationship with any perception item, despite being a core dimension of welfare state research.

## Methods

This project proceeds through progressive levels of analysis (for now, only Bivariate Correlation (1) is available in this github):

1. **Bivariate correlation** — Pearson correlations between each institutional variable and each RTM item *(completed)*
2. **Simple OLS regression** — Estimating the slope: how much does perception change per unit of institutional difference? *(in progress)*
3. **Multiple regression** — Which institutional dimension matters most, controlling for the others?
4. **Principal Component Analysis** — Reducing 9 perception items to underlying dimensions
5. **Cluster analysis** — Do countries group into recognisable welfare regime types based on perception profiles?

## Project Structure

```
├── data-source/          # Raw data files and sourcing notes
├── scripts/              # R analysis scripts (numbered sequentially)
├── output/               # Generated plots, tables, and merged dataset
└── README.md
```

## How to Run

```r
source("scripts/00_setup.R")              # Install packages (once)
source("scripts/01_data_preparation.R")   # Load, clean, merge datasets
source("scripts/02_bivariate_correlation_analysis.R")  # Run correlations
```

## Limitations

- **Small N (27 countries):** Limited statistical power. Effect sizes and patterns are more informative than p-values alone.
- **Cross-sectional design:** These are associations, not causal claims. Reverse causality and omitted variable bias cannot be ruled out.
- **Aggregate data:** Country-level percentages lose individual-level variation. Multilevel models with survey microdata would be the appropriate next step.
- **Temporal mismatch:** EPL data ends in 2019; the RTM survey was conducted in 2024. Institutional features change slowly, but the gap should be acknowledged.

