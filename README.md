# ONCO26 Oncology Phase III Clinical Trial — SAS Analysis Pipeline

A modular SAS macro pipeline for a simulated oncology Phase III clinical trial, following CDISC ADaM standards. It covers data import, analysis dataset construction, survival analysis, and Cox regression.

---

## Project Overview

ONCO-2026 is a simulated Phase III, double-blind, 1:1 randomized oncology trial with 500 patients. Patients were randomized to either the active treatment arm (ARM A) or placebo arm (ARM B). The primary endpoint is Overall Survival (OS).

This project uses SAS macros to automate the full analysis workflow, from raw CSV data to statistical results.

---

## Features

### CDISC ADaM Datasets
- **ADSL** — Subject-Level Analysis Dataset
- **ADTTE** — Time-to-Event Analysis Dataset

### Statistical Analysis
- Kaplan-Meier survival curves
- Log-rank test
- Cox proportional hazards regression
- Hazard ratio with 95% confidence interval

### SAS Macro Library
- `%import_csv` — Parameterized CSV import
- `%build_adsl` — Standardized ADSL construction
- `%build_adtte` — Standardized ADTTE construction
- `%km_analysis` — Automated Kaplan-Meier analysis
- `%cox_analysis` — Automated Cox regression
- `%onco26_pipeline` — One-click full pipeline

---

## Requirements

- SAS 9.4 or SAS OnDemand for Academics
- Dataset: [Kaggle ONCO26](https://www.kaggle.com/datasets/auro15/onco26-oncology-phase-iii-clinical-trial-dataset)

---

## Quick Start

1. Upload `macro/` and `program/` to your SAS environment.
2. Modify `macros/00_setup.sas` to set your own data path.
3. Run `programs/99_run_all.sas`.
4. Check the log and output for results.

---

## Key Results

| Analysis | Result |
|----------|--------|
| Median OS (ARM A) | 730 days (not reached) |
| Median OS (ARM B) | 665 days |
| Log-rank P-value | 0.2316 |
| Adjusted HR (95% CI) | 0.889 (0.687–1.152) |
| Adjusted P-value | 0.3732 |
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
