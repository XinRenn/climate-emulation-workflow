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
| 1a | `SSP/0.Create_SSP_emissions.ipynb` | `SSP/raw_emissions/CO2_emissions_{scenario}.txt` |
| 1a | `SSP/0.create_10000pgc_emission.ipynb` | `SSP/raw_emissions/CO2_emissions_10000pgc.txt` |
| 1b | `1.Convoluted_response_function.ipynb` | `SSP/concentration_ppmv/CO2_{scenario}_ppmv.txt` |
| 1c | `2.make_CO2_ppmv_data_in_ka.ipynb` | `SSP/concentration_ppmv/CO2_data_{scenario}_0-1ma.res` |

Key parameter: `Historical_emissions = 283.962 GtC` (fossil-only cumulative 1765–2000, following Lord et al. 2017).

### Stage 2 — GSL (Global Sea Level) model
Folder: `2_GSL_model/`

| Step | Script | Notes |
|------|--------|-------|
| Run1 | `Run1_Create_Samp_SSP_upd_1myr_AP.ipynb` | Python — creates LHC orbital+ice samples |
| Run2 | `Run2_AG2005_CGSLM_LH_and_plot.m` | **MATLAB — run manually** — CGSLM + LHC, saves raw emulator inputs |
| Run3 | `Run3_updated_CO2_from_RSL_LHC.m` | **MATLAB — run manually** — CO₂ correction for glacial sea-level feedback |
| Run4 | `Run4_update_CO2_LHC_members.ipynb` | Python — applies updated CO₂ across all 90 LHC members |
| Plot | `Plot_Figure3.1_CO2+GSL.ipynb` | Python — Figure 3.1: CO₂ and GSL time-series for 6 scenarios |

Output structure under `results/`:
- `results/emul_inputs_raw/` — raw emulator inputs from Run2 (per scenario × 90 members)
- `results/emul_inputs_updatedCO2/` — CO₂-corrected inputs from Run4 (used by Stage 3)
- `results/LHCsamps/` — LHC sample files

### Stage 3 — Emulator training and prediction
Folder: `3_emulator/`

Runs on Bristol HPC (BC4) via SLURM. See `3_emulator/README_server.md` for environment setup.

```bash
# Submit job on BC4
conda activate emu
sbatch submit_prediction.slurm
```

Each `(var, state)` batch is saved to `outputs/{var}_{state}/` on the server with a `.done` marker on completion. Pull from local Mac after each batch (or at the end):

```bash
rsync -av --remove-source-files \
    bo20541@bc4login.acrc.bris.ac.uk:/path/to/3_emulator/outputs/ \
    /Volumes/Xin-data/NWS_outputs/
```

Scripts:
- `run_prediction_slurm.py` — server version (saves to server, pull separately)
- `run_prediction.py` — local version (moves directly to `target_dir`)

Output: NetCDF predictions in `/Volumes/Xin-data/NWS_outputs/{var}_{state}/` (external drive).

### Stage 4 — Plots and validation
Folder: `4_plots/`

Analysis notebooks for validation and report figures.

---

## Scenarios

6 scenarios used across all stages:

| Label | Description | File tag |
|-------|-------------|----------|
| natural | No anthropogenic emissions | `natural` |
| SSP1-26 | SSP1-2.6 | `SSP126` |
| SSP2-45 | SSP2-4.5 | `SSP245` |
| SSP3-70 | SSP3-7.0 | `SSP370` |
| SSP5-85 | SSP5-8.5 | `SSP585` |
| 10000pgc | 10,000 PgC extreme scenario | `10000PGC` |

> **Note:** `SSP119` forcing files exist in `results/emul_inputs_updatedCO2/` but are excluded from emulator prediction and plotting.

Stages 1–2 are rerun for all **non-natural** scenarios (5 total) when `Historical_emissions` changes.

---

## Environment

| Context | Command |
|---------|---------|
| Local Python | `conda activate emu` (or `source TONIC-Oligocene/paleo-emu/.venv/bin/activate`) |
| Server (BC4) | `conda activate emu` — `paleo_emu` installed from `TONIC-Oligocene/paleo-emu/` |
| MATLAB | R2022b or later |

`paleo_emu` package: `pip install -e TONIC-Oligocene/paleo-emu/`

---

## Downscaling
See `downscale/` — runs on the Bristol HPC. See `downscale/README_downscale.md`.
