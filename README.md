# 🧬 Clinical Trials SAS Programming — CDISC SDTM & ADaM Pipeline

> **Internship project** — Gurus LLC, Yerevan, Armenia  
> **Programmer:** Syuzanna Ghazaryan | **Supervisor:** Hayk Nazaryan  
> **University:** UFAR / Université Toulouse 3 – Paul Sabatier | **Period:** 7 weeks | 2026

---

## 📋 Project Overview

A **complete, production-style SAS programming pipeline** for clinical trial data processing, following international regulatory standards (**CDISC**, **FDA**, **ICH**).

```
Raw Source Data  ──►  SDTM Domains  ──►  ADaM Datasets  ──►  TLFs
```

### Simulated Study Design

| Parameter | Value |
|-----------|-------|
| Study ID | STUDY001 |
| Phase | Phase II |
| Design | Randomised, Double-blind, Placebo-controlled |
| Arms | Drug A 100mg (n=30) vs Placebo (n=30) |
| Duration | 12 weeks + Follow-up |

---

## 🏗️ Repository Structure

```
clinical-sas-project/
├── data/
│   ├── raw/          # Simulated CSV source data
│   ├── sdtm/         # SDTM output datasets (generated)
│   └── adam/         # ADaM output datasets (generated)
├── programs/
│   ├── macros/       # Reusable SAS macro library
│   ├── sdtm/         # SDTM mapping programs (DM, VS, AE, EX)
│   ├── adam/         # ADaM programs (ADSL, ADAE)
│   └── tlf/          # Tables, Listings, Figures
├── outputs/
│   ├── tlf/          # Generated RTF outputs
│   └── logs/         # SAS log files
├── docs/             # Study documentation
├── tests/            # QC / double-programming scripts
├── setup_libraries.sas
└── run_all.sas
```

---

## 📦 SDTM Domains

| Domain | Class | Description |
|--------|-------|-------------|
| DM | Special Purpose | Demographics |
| VS | Findings | Vital Signs |
| AE | Events | Adverse Events |
| EX | Interventions | Exposure / Treatment |

## 📊 ADaM Datasets

| Dataset | Key Derived Variables |
|---------|----------------------|
| ADSL | SAFFL, ITTFL, PPROTFL, AGEGR1, TRTDURD |
| ADAE | TRTEMFL, AESEV, AEREL, ASTDT, AENDT |

---

## 🚀 Quick Start

1. Edit `setup_libraries.sas` — set `%LET root = /path/to/project;`
2. Run `setup_libraries.sas`
3. Run `run_all.sas`

---

## 📐 Standards

- SDTM IG v3.4 | ADaM IG v1.3 | FDA Technical Conformance Guide 2023

---

## 👩‍💻 Author

**Syuzanna Ghazaryan** — Licence Informatique, UFAR / UT3  
Internship at [Gurus LLC](https://gurus.am) | Supervisor: Hayk Nazaryan | 2026

> Source data is fully simulated — no real patient data included.
