# outputs/logs/

This folder stores **SAS log files** produced during program execution.

## Log file naming convention

| Pattern | Example | Description |
|---------|---------|-------------|
| `sdtm_<domain>.log` | `sdtm_vs.log` | SDTM mapping program log |
| `adam_<dataset>.log` | `adam_adsl.log` | ADaM construction program log |
| `tlf_<output>.log` | `tlf_t_14_1_1.log` | TLF program log |
| `run_all.log` | `run_all.log` | Full pipeline execution log |

## What to check in logs

Always review logs for:
- `ERROR:` — fatal issues that stopped execution
- `WARNING:` — potential data or logic issues
- `NOTE: MERGE statement has more than one data set with repeats` — unexpected many-to-many merge
- `NOTE: Variable X is uninitialized` — missing variable reference
- Obs counts at each DATA step — verify no unexpected record loss

## QC log review checklist

```
1. Zero ERROR lines
2. Zero unexpected WARNING lines  
3. Input/output obs counts match expectations
4. No uninitialized variable notes
5. PROC COMPARE shows 0 differences (double-programming QC)
```

## Note

Log files are excluded from version control (`.gitignore`).  
Always save logs when submitting to a sponsor or regulatory authority.
