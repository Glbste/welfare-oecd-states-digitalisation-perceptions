# Welfare State Institutions and Digitalisation Perceptions

A cross-national analysis of how welfare state institutions shape citizens' perceptions of digitalisation, using the 2024 OECD Risks That Matter survey.

## Research Question

Do the institutional characteristics of a country's welfare state (social spending, employment protection, and labour organisation) predict how citizens perceive the impact of digitalisation on their working lives?

## Data

| File | Source | Description |
|------|--------|-------------|
| `1-2024-RTM.xlsx` | [OECD Risks That Matter 2024](https://www.oecd.org/en/about/programmes/oecd-risks-that-matter-rtm-survey.html) | Digitalisation perceptions: 9 survey items across 27 countries |
| `2-ICTWSS.csv` | [ICTWSS Database v2](https://www.oecd.org/en/data/datasets/oecdaias-ictwss-database.html) | Union density (% of employees who are trade union members) |
| `3-OECD-EPL.csv` | [OECD Employment Protection Database](https://data-explorer.oecd.org/vis?df[ds]=DisseminateFinalDMZ&df[id]=DSD_EPL%40DF_EPL&df[ag]=OECD.ELS.JAI&dq=A..EPL_OV..VERSION4&pd=2000%2C&to[TIME_PERIOD]=false) | Employment Protection Legislation index (0–6 scale, Version 4) |
| `4-OECD_SOCX.csv` | [OECD Social Expenditure Database](https://data-explorer.oecd.org/vis?fs[0]=Topic%2C1%7CSociety%23SOC%23%7CSocial%20policy%23SOC_PRO%23&pg=0&fc=Topic&bp=true&snb=12&df[ds]=dsDisseminateFinalDMZ&df[id]=DSD_SOCX_AGG%40DF_SOCX_AGG&df[ag]=OECD.ELS.SPD&df[vs]=1.0&dq=.A..PT_B1GQ.ES10._T._T.&pd=2010%2C&to[TIME_PERIOD]=false) | Public social expenditure as % of GDP |

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

