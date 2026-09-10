# ONCO26 Oncology Phase III Clinical Trial — SAS Analysis Pipeline

A modular SAS macro pipeline for a simulated oncology Phase III clinical trial, following CDISC ADaM standards. It covers data import, analysis dataset construction, survival analysis, safety analysis, and automated report generation.

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

### Statistical Analysis
- Kaplan-Meier survival curves with number-at-risk table
- Log-rank test
- Cox proportional hazards regression (adjusted HR with 95% CI)

### Safety Analysis
- Treatment-emergent adverse event (TEAE) summary
- TEAE by preferred term and treatment group
- TEAE by severity and treatment group
- Serious AE and drug-related AE summary
- Formatted RTF output

### SAS Macro Library
- `%import_csv` — Parameterized CSV import
- `%build_adsl` / `%build_adtte` / `%build_adae` — Standardized dataset construction
- `%km_analysis` / `%cox_analysis` — Automated statistical analysis
- `%safety_analysis` — Formatted safety tables
- `%onco26_pipeline` — One-click full pipeline (8 steps)

---

## Requirements

- SAS 9.4 or SAS OnDemand for Academics
- Dataset: [Kaggle ONCO26](https://www.kaggle.com/datasets/auro15/onco26-oncology-phase-iii-clinical-trial-dataset)

---

## Quick Start

1. Upload `macros/` and `programs/` to your SAS environment.
2. Modify `macros/00_setup.sas` to set your own data path.
3. Run `programs/99_run_all.sas`.
4. Check the log, output window, and `output/` directory for results.

---

## Key Results

| Analysis | Result |
|----------|--------|
| Median OS (ARM A) | 730 days (not reached) |
| Median OS (ARM B) | 665 days |
| Log-rank P-value | 0.2316 |
| Adjusted HR (95% CI) | 0.889 (0.687–1.152) |
| Adjusted P-value | 0.3732 |
| TEAE records | 2692 (100%) |
| Serious AEs | 350 (13.0%) |
| Drug-related AEs | 1512 (56.2%) |
| BMI missing | 18 (3.6%), complete-case analysis |

---

## Technical Stack

- **SAS 9.4** — Base SAS, SAS/STAT
- **CDISC** — ADaM Implementation Guide
- **Output** — ODS RTF, ODS PDF, ODS Graphics
- **Programming** — SAS Macro Language

---

## Author

Wang Guosheng  
Harbin Medical University  
2024020757@hrbmu.edu.cn

---

## License

For academic and learning purposes only.  
Dataset copyright belongs to Kaggle and the original author.
