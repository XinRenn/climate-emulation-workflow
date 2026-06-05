# NWS Climate Emulation Workflow

End-to-end workflow for emulating HadCM3 climate over 1 Ma, for NWS long-term UK prediction project.


---

## Workflow Overview

```
Stage 1 (local, Python)   →  Stage 2 (local, MATLAB + Python)  →  Stage 3 (server, Python)
1_CO2_model/                 2_GSL_model/                          3_emulator/
                                                                         ↓
                             Stage 5 (local, Python)            Stage 4 (local, Python)
                             5_plots/                            4_downscale/
```

---

### Stage 1 — CO₂ concentration model
**Folder:** `1_CO2_model/`  ✅ Complete

| Step | Notebook | Output |
|------|----------|--------|
| 0a | `SSP/0.Create_SSP_emissions.ipynb` | `SSP/raw_emissions/CO2_emissions_{scenario}.txt` |
| 0b | `SSP/0.create_10000pgc_emission.ipynb` | `SSP/raw_emissions/CO2_emissions_10000pgc.txt` |
| Run1 | `Run1_Convoluted_response_function.ipynb` | `SSP/concentration_ppmv/CO2_{scenario}_ppmv.txt` |
| Run2 | `Run2_make_CO2_ppmv_data_in_ka.ipynb` | `SSP/concentration_ppmv/CO2_data_{scenario}_0-1ma.res` |
| Diag | `diag_compare_CO2_emissions.ipynb` | diagnostic comparison plots |

Key parameter: `Historical_emissions = 283.962 GtC` (cumulative CO₂ 1765–2000, see comment in Run1).

---

### Stage 2 — GSL (Global Sea Level) model
**Folder:** `2_GSL_model/`  ✅ Complete

| Step | Script | Location | Notes |
|------|--------|----------|-------|
| Run1 | `Run1_Create_Samp_SSP_upd_1myr_AP.ipynb` | `2_GSL_model/` | Python — LHC orbital+ice samples |
| Run2 | `Archer_Ganopolski_2005_rcp_4_1myrAP_LHC_sens_test_atka_Xin.m` | `Conceptual-GSL/PosivaSKB-master/` | **MATLAB — run manually** |
| Run3 | `updated_CO2_from_RSL_rcp_4_1myrAP_from800kyrBP_RCP_LHC_Xin.m` | `Conceptual-GSL/PosivaSKB-master/` | **MATLAB — run manually** |
| Run4 | `Run4_update_CO2_LHC_members.ipynb` | `2_GSL_model/` | Python — applies updated CO₂ across 90 LHC members |
| Diag | `diag_compare_results.py` | `2_GSL_model/` | diagnostic comparison |

Output: `results/emul_inputs_updatedCO2/emul_inputs_{scenario}.{member}.updated.res`  
(6 scenarios × 90 members = 540 files — used by Stages 3 and 5)

---

### Stage 3 — Emulator prediction
**Folder:** `3_emulator/`  ⏳ In progress (running on BluePebble HPC)

Runs on **BluePebble** (`bp1-login04.acrc.bris.ac.uk`) via SLURM. See `3_emulator/README_server.md` for environment setup.

```bash
# Submit on BluePebble
conda activate paleo-emu
sbatch submit_prediction.slurm.sh
```

Output files are saved flat to the server `outputs/` directory, then pulled to the local Mac continuously using the rsync daemon:

```bash
# Start 12-worker pull daemon (2 ice states × 6 scenarios in parallel)
bash 3_emulator/rsync_nws.sh

# Stop daemon
bash 3_emulator/rsync_nws.sh stop

# Monitor
tail -f /tmp/rsync_nws.log
```

**Output:** `/Volumes/Xin-data/NWS_outputs/{var}_{state}_{scen}_{member}_prediction.nc`  
(flat directory — no subdirectories)

Variables (10): `tas`, `precip`, `evap`, `windspeed`, `ice_sheet`, `iceconc`, `LAI_PFT`, `snowdepth`, `sm`, `soiltemp`  
Ice states (2): `modhighice`, `modlowice`  
Scenarios (6): see table below  
Members: 90  
Total: ~10,800 NetCDF files (~1 TB)

---

### Stage 4 — Downscaling
**Folder:** `4_downscale/`

See `4_downscale/README_downscale.md`.

---

### Stage 5 — Site extraction and plots
**Folder:** `5_plots/`

#### 5a — Extract UK site data
Script: `Run1_extract_uk_sites.py`

Reads prediction NetCDF files from `/Volumes/Xin-data/NWS_outputs/` and extracts values at 6 UK HadCM3 grid points. Ice-state selection per timestep: GSL < 0 → modhighice; GSL ≥ 0 → modlowice.

```bash
conda activate emu
cd 5_plots/
python Run1_extract_uk_sites.py
```

**UK sites (HadCM3 grid indices):**

| Site | Type | lat index | lon index |
|------|------|-----------|-----------|
| LA | land | 14 | −1 |
| LB | land | 15 | −1 |
| LC | land | 15 | 0 |
| LD | land | 16 | 0 |
| SA | sea  | 16 | −1 |
| SB | sea  | 15 | +1 |

**Output:** `5_plots/site_data/site_{LA|LB|LC|LD|SA|SB}/{var}_{scen}_site_{site}.txt`  
Shape: 90 members × 1001 time steps. NWS-compliant: `.txt`, flat structure, metadata header.  
Note: `iceconc` uses sea sites (SA, SB) only.

#### 5b — Plot notebooks

| Notebook | Figure | Requires |
|----------|--------|----------|
| `Plot_Figure3.1_CO2+GSL.ipynb` | CO₂ and GSL time series | Stage 2 outputs |
| `Plot_FigureA1_Get_regime_threshold.ipynb` | SAT at GSL thresholds → set regime bounds | `tas` site data |
| `Plot_Figure3.4_prediction_on_site.ipynb` | All members + mean, per variable per scenario | site data |
| `Plot_Figure3.5_strip_SAT.ipynb` | Stacked area: warm/cold/mid SAT regimes | `tas` site data |
| `Plot_Figure3.6_strip_IS.ipynb` | Stacked area: ice sheet presence | `ice_sheet` site data |
| `Plot_Figure3.6(1)_strip_IS_4regime.ipynb` | 4 regimes (aerial/undersea × ice/no-ice), 90 members | `ice_sheet` + GSL |
| `Plot_Figure3.6(2)_strip_IS_4regime_member67.ipynb` | Same 4 regimes, member 67 only | `ice_sheet` + GSL |
| `Plot_Figure3.6(3)_strip_IS_member67.ipynb` | Ice sheet strip, member 67 | `ice_sheet` site data |
| `Check_iceconc_on_UK.ipynb` | Diagnostic: sea ice concentration at UK sites | `iceconc` site data |

All notebooks read site data from `site_data/` (relative to `5_plots/`).  
GSL inputs: `../2_GSL_model/results/emul_inputs_updatedCO2/`.

---

## Scenarios

| Label | Description | File tag |
|-------|-------------|----------|
| Natural | No anthropogenic emissions | `natural` |
| SSP1-2.6 | SSP1-2.6 | `SSP126` |
| SSP2-4.5 | SSP2-4.5 | `SSP245` |
| SSP3-7.0 | SSP3-7.0 | `SSP370` |
| SSP5-8.5 | SSP5-8.5 | `SSP585` |
| 10,000 PgC | Extreme scenario | `10000PGC` |

> **Note:** `SSP119` forcing files exist in `results/emul_inputs_updatedCO2/` but are excluded from emulator prediction and plotting.

---

## Environment

| Context | Command |
|---------|---------|
| Local Python | `conda activate emu` |
| Server (BluePebble) | `conda activate paleo-emu` |
| MATLAB | R2022b or later (Stages 2 Run2/Run3) |

`paleo_emu` package: `pip install -e TONIC-Oligocene/paleo-emu/`

