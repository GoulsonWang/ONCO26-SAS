# ONCO26 Oncology Phase III Clinical Trial — SAS Analysis Pipeline

A modular SAS macro pipeline for a simulated oncology Phase III clinical trial, following CDISC ADaM standards. It covers data import, analysis dataset construction, survival analysis, subgroup analysis, safety analysis, and automated report generation.

---

## Project Overview

ONCO-2026 is a simulated Phase III, double-blind, 1:1 randomized oncology trial with 500 patients. Patients were randomized to either the active treatment arm (ARM A) or placebo arm (ARM B). The primary endpoint is Overall Survival (OS).

This project uses SAS macros to automate the full analysis workflow, from raw CSV data to statistical results and formatted reports.
---

## Features

### CDISC ADaM Datasets
- **ADSL** — Subject-Level Analysis Dataset (demographics, treatment, TRTSDT)
- **ADTTE** — Time-to-Event Analysis Dataset (OS with standardized CNSR)
- **ADAE** — Adverse Event Analysis Dataset (TEAE, severity, seriousness, relatedness)
- **ADLB** — Laboratory Analysis Dataset (ANRIND, BNRIND, SHIFT)

### Statistical Analysis
- Kaplan-Meier survival curves with number-at-risk table
- Log-rank test
- Cox proportional hazards regression (adjusted HR with 95% CI)
- Subgroup analysis across age, BMI, and sex
- Forest plot visualization
- Proportional hazards assumption test (supremum test)
- Logistic regression for binary safety endpoints

### Safety Analysis
- Treatment-emergent adverse event (TEAE) summary
- TEAE by preferred term, severity, and treatment group
- Serious AE and drug-related AE summary
- Lab shift table (baseline to post-baseline)
- Formatted RTF output

### SAS Macro Library
- `%import_csv` — Parameterized CSV import
- `%build_adsl` / `%build_adtte` / `%build_adae` / `%build_adlb` — Standardized dataset construction
- `%km_analysis` / `%cox_analysis` — Automated statistical analysis
- `%subgroup_analysis` / `%forest_plot` / `%ph_assumption` / `%logistic_analysis` — Advanced analytics
- `%safety_analysis` / `%lab_analysis` — Formatted safety and lab tables
- `%onco26_pipeline` — One-click full pipeline (13 steps)

---

## Requirements

- SAS 9.4 or SAS OnDemand for Academics
- Dataset: [Kaggle ONCO26](https://www.kaggle.com/datasets/auro15/onco26-oncology-phase-iii-clinical-trial-dataset)

---

## Quick Start

1. Upload `macros/` and `programs/` to your SAS environment.
2. Modify `macros/00_setup.sas` to set your own data path.
3. Run `programs/99_run_all.sas`.
4. Check the log, output window, and output directory for results.

---

## Key Results

| Analysis | Result |
|----------|--------|
| Median OS (ARM A) | 730 days (not reached) |
| Median OS (ARM B) | 665 days |
| Log-rank P-value | 0.2316 |
| Adjusted HR (95% CI) | 0.889 (0.687–1.152) |
| Adjusted P-value | 0.3732 |
| PH assumption | All p > 0.05 (satisfied) |
| Subgroup HR range | 0.809 – 0.934 |
| TEAE records | 2692 (100%) |
| Serious AEs | 350 (13.0%) |
| Drug-related AEs | 1512 (56.2%) |
| SAE odds ratio (Active vs Placebo) | 1.872 (1.307–2.681) |
| Lab: NORMAL to HIGH | 476 records |
| Lab: NORMAL to LOW | 816 records |
| BMI missing | 18 (3.6%), complete-case analysis |

---

## Technical Stack

- **SAS 9.4** — Base SAS, SAS/STAT
- **CDISC** — ADaM Implementation Guide
- **Output** — ODS RTF, ODS PDF, ODS Graphics
- **Programming** — SAS Macro Language, parameterized programming

---



---

## Author

Wang Guosheng  
Harbin Medical University  
2024020757@hrbmu.edu.cn

---

## License

For academic and learning purposes only.  
Dataset copyright belongs to Kaggle and the original author.
