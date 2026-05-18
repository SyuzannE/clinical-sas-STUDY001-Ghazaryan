# Data Specifications — STUDY001

## Source Data Files

### demographics.csv
| Variable | Type | Description | Values |
|----------|------|-------------|--------|
| SUBJID | Char | Subject identifier | 001–015 |
| SITEID | Char | Site identifier | 01–04 |
| AGE | Num | Age in years | 18–80 |
| SEX | Char | Sex | M, F |
| RACE | Char | Race | WHITE, BLACK OR AFRICAN AMERICAN, ASIAN, HISPANIC OR LATINO |
| COUNTRY | Char | Country | ARM |
| ARM | Char | Treatment arm | Drug A, Placebo |
| RANDDT | Char | Randomisation date | YYYY-MM-DD |
| RFSTDTC | Char | Study start date | YYYY-MM-DD |
| RFENDTC | Char | Study end date | YYYY-MM-DD |
| COMPFL | Char | Completed study flag | Y, N |
| DTHFL | Char | Death flag | Y, N |

### vitals.csv
| Variable | Type | Description | Units |
|----------|------|-------------|-------|
| SUBJID | Char | Subject identifier | — |
| VISIT | Char | Visit name | Baseline, Week 4, Week 8, Week 12 |
| VISITNUM | Num | Visit number | 1–4 |
| VSDAT | Char | Assessment date | YYYY-MM-DD |
| SYSBP | Num | Systolic blood pressure | mmHg |
| DIABP | Num | Diastolic blood pressure | mmHg |
| HR | Num | Heart rate | beats/min |
| WEIGHT | Num | Body weight | kg |
| HEIGHT | Num | Height | cm |
| VSPOS | Char | Subject position | STANDING |

### adverse_events.csv
| Variable | Type | Description | Values |
|----------|------|-------------|--------|
| SUBJID | Char | Subject identifier | — |
| AETERM | Char | AE verbatim term | Free text |
| AEBODSYS | Char | System organ class | MedDRA SOC |
| AESTDAT | Char | AE start date | YYYY-MM-DD |
| AEENDAT | Char | AE end date | YYYY-MM-DD |
| AESEV | Char | Severity | MILD, MODERATE, SEVERE |
| AEREL | Char | Causality | NOT RELATED, UNLIKELY, POSSIBLE, PROBABLE |
| AEOUT | Char | Outcome | RECOVERED/RESOLVED, RECOVERING/RESOLVING, NOT RECOVERED/NOT RESOLVED |
| AESER | Char | Serious AE flag | Y, N |

### exposure.csv
| Variable | Type | Description | Values |
|----------|------|-------------|--------|
| SUBJID | Char | Subject identifier | — |
| EXTRT | Char | Treatment name | Drug A, Placebo |
| EXDOSE | Num | Dose | 100 (Drug A), 0 (Placebo) |
| EXDOSU | Char | Dose units | mg |
| EXROUTE | Char | Route | ORAL |
| EXSTDAT | Char | Start date | YYYY-MM-DD |
| EXENDAT | Char | End date | YYYY-MM-DD |
| EXDOSFRQ | Char | Frequency | QD |

---

## SDTM → ADaM Variable Mapping

### Key population flags in ADSL

| Flag | Variable | Criterion |
|------|----------|-----------|
| Safety | SAFFL | Received ≥1 dose (TRTSDT not missing) |
| Intent-to-Treat | ITTFL | Randomised (RFSTDTC not missing) |
| Per-Protocol | PPROTFL | Completed study (COMPFL=Y) |

### TRTEMFL derivation (ADAE)

```
TRTEMFL = "Y" if:
  AE start date (ASTDT) >= First dose date (TRTSDT)
  AND AE end date (AENDT) <= Last dose date (TRTEDTM) + 30 days
  (or AENDT is missing)
```
