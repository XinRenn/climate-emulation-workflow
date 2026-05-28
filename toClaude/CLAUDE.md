# CLAUDE.md

This file provides guidance to Claude Code when working in the `climate_emulation_workflow/` repository.

## What This Repository Is

Clean workflow repo for Xin Ren (University of Bristol, NWS PDRA project).
GitHub: https://github.com/XinRenn/climate-emulation-workflow (private)
Local path: `OneDrive-UniversityofBristol/NWS-PDRA/climate_emulation_workflow/`

Contains all code needed to run the end-to-end HadCM3 climate emulation over 1 Ma for UK nuclear waste repository site assessment.

The ML emulator package (`paleo_emu`) lives separately at:
`OneDrive-UniversityofBristol/TONIC-Oligocene/paleo-emu/`

Original working directories (do NOT edit directly unless noted):
- `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/` — Stage 1 & 2 source
- `NWS-PDRA/NWS_emulation/` — Stage 3 & 4 source

## Repository Structure

```
climate_emulation_workflow/
  1_CO2_model/                    # Stage 1: CO₂ response function
    1.Convoluted_response_function.ipynb   # Lord et al. convolution (Historical_emissions here)
    2.make_CO2_ppmv_data_in_ka.ipynb       # Convert to 1 Ma format → 2_GSL_model/ForcingData/
    Time.txt                               # Time axis 1–1,000,000 AP years
    SSP/                                   # SSP emissions input data + generation notebooks
  2_GSL_model/                    # Stage 2: GSL model (MATLAB + Python)
    Archer_Ganopolski_2005_rcp_4_1myrAP_LHC_sens_test_atka_Xin.m  # step 2a (manual MATLAB)
    plot_Figure3_4a_Xin.m                  # step 2b (manual MATLAB)
    inputX/orig/Create_Samp_SSP_upd_1myr_AP.ipynb  # step 2c (Python)
    updated_CO2_from_RSL_rcp_4_1myrAP_from800kyrBP_RCP_Xin.m  # step 2d (manual MATLAB)
    update_CO2_LHC_members.ipynb           # step 2e (Python)
    ForcingData/                           # Reference forcing data (CO2, insolation)
  3_emulator/                     # Stage 3: emulator training & prediction (runs on server)
    run_prediction.py              # Entry point
    prediction.yml                 # Config (paths, model params, scenarios)
    README_server.md               # Server setup instructions
    LOO_validation/                # Leave-one-out validation scripts
    UK_site_data/                  # Site extraction scripts + UK_sites_index.res
  4_plots/                        # Stage 4: analysis and report figures
  downscale/                      # Placeholder — HPC downscaling scripts
    README_downscale.md
  toClaude/                       # This folder — conversation context files
    CLAUDE.md                     # This file
    tasks.md                      # Task list with current progress
```

## Code Modification Rules (this repo only)

1. **No `CC_` prefix required** for new files in this repo.
2. **Minimal changes** to copied code — only change what is necessary.
3. **Always notify the user before modifying any code file.**
4. **Backup before editing**: copy to `{original_name}_backup_{YYYYMMDD}` in the same directory before any edit.

> The original working directories (`TONIC-Oligocene/`, `NWS-PDRA/NWS_emulation/`) still follow the original rules: backup + `CC_` prefix for all Claude-created files.

## Key Parameters

| Parameter | Value | Location |
|-----------|-------|----------|
| `Historical_emissions` | **283.962 GtC** | `1_CO2_model/1.Convoluted_response_function.ipynb` |
| GSL threshold | -28 m | used in 4_plots ice regime notebooks |
| Ice states | `modhighice`, `modlowice` | `3_emulator/prediction.yml` |
| Variables emulated | `tas`, `precip`, `evap`, `windspeed`, `ice_sheet`, `iceconc`, `LAI_PFT`, `snowdepth`, `sm`, `soiltemp` | — |

`Historical_emissions = 283.962 GtC` is fossil-only cumulative CO₂ 1765–2000 inclusive, following Lord et al. (2017). The SSP emissions files start from year 2000 (`year > 1999`). Original wrong value was 355.558 (fossil-only to ~2010, Lord's 2010-start setup which doesn't apply here).

## Workflow Summary

```
Stage 1 (local, Python)    →   Stage 2 (local, MATLAB+Python)  →   Stage 3 (server, Python)
1_CO2_model/                   2_GSL_model/                         3_emulator/
```

Full step-by-step progress tracked in `toClaude/tasks.md`.

## Running Stage 3

```bash
conda activate paleo-emu
cd 3_emulator/
python run_prediction.py
```

See `3_emulator/README_server.md` for full setup.

## Scenarios

| Label | Description |
|-------|-------------|
| natural | No anthropogenic emissions (no rerun needed for Task 7) |
| SSP1-19 | SSP1-1.9 |
| SSP1-26 | SSP1-2.6 |
| SSP2-45 | SSP2-4.5 |
| SSP3-70 | SSP3-7.0 |
| SSP4-60 | SSP4-6.0 |
| SSP5-34 | SSP5-3.4 |
| SSP5-85 | SSP5-8.5 |
| 10000pgc | 10,000 PgC extreme scenario |
