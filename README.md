# NWS Climate Emulation Workflow

End-to-end workflow for emulating HadCM3 climate over 1 Ma, for post-closure performance assessments of UK nuclear waste repositories.

**Reference:** Builds on Lord et al. (2017) and TR-19-09.

---

## Workflow Overview

```
Stage 1 (local, Python)     →  Stage 2 (local, MATLAB + Python)  →  Stage 3 (server, Python)
1_CO2_model/                   2_GSL_model/                          3_emulator/
```

### Stage 1 — CO₂ concentration model
Folder: `1_CO2_model/`

| Step | Notebook/Script | Output |
|------|----------------|--------|
| 1a | `Create_SSP_emissions.ipynb` | `SSP/CO2_emissions_{scenario}.txt` |
| 1b | `Convoluted_response_function.ipynb` | `SSP/CO2_{scenario}_ppmv.txt` |
| 1c | `make_CO2_ppmv_data_in_ka.ipynb` | `updated_CO2_from_SL_1myr_AP_from800kyrBP—RCP_Xin.res` |

Key parameter: `Historical_emissions = 283.962 GtC` (fossil-only cumulative 1765–1999, following Lord et al. 2017).

### Stage 2 — GSL (Global Sea Level) model
Folder: `2_GSL_model/`

| Step | Script | Notes |
|------|--------|-------|
| 2a | `Archer_Ganopolski_2005_rcp_4_1myrAP_LHC_sens_test_atka_Xin.m` | **MATLAB — run manually** |
| 2b | `plot_Figure3_4a_Xin.m` | **MATLAB — run manually** |
| 2c | `inputX/orig/Create_Samp_SSP_upd_1myr_AP.ipynb` | Python |
| 2d | `updated_CO2_from_RSL_rcp_4_1myrAP_from800kyrBP_RCP_LHC_Xin.m` | **MATLAB — run manually** |
| 2e | `update_CO2_LHC_members.ipynb` | Python |

Output: `Results/emul_inputs_{scenario}.{member}.updated.res` (90 members × 6 scenarios)

### Stage 3 — Emulator training and prediction
Folder: `3_emulator/`

Runs on server. See `3_emulator/README_server.md` for environment setup.

```bash
conda activate paleo-emu
cd 3_emulator/
python run_prediction.py
```

Output: NetCDF predictions to `/Volumes/Xin-data/result/` (external drive).

### Stage 4 — Plots and validation
Folder: `4_plots/`

Analysis notebooks for validation and report figures.

---

## Scenarios

| Label | Description |
|-------|-------------|
| natural | No anthropogenic emissions |
| SSP1-19 | SSP1-1.9 |
| SSP1-26 | SSP1-2.6 |
| SSP2-45 | SSP2-4.5 |
| SSP3-70 | SSP3-7.0 |
| SSP4-60 | SSP4-6.0 |
| SSP5-34 | SSP5-3.4 |
| SSP5-85 | SSP5-8.5 |
| 10000pgc | 10,000 PgC extreme scenario |

Stages 1–2 are rerun for all **non-natural** scenarios (8 total) when `Historical_emissions` changes.

---

## Environment

Python: `conda activate paleo-emu` (see `TONIC-Oligocene/paleo-emu/` for package install).

MATLAB: R2022b or later.

---

## Downscaling
See `downscale/` — runs on the Bristol HPC. See `downscale/README_downscale.md`.
