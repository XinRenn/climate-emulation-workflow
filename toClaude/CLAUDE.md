# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is the NWS (Nuclear Waste Storage) PDRA project workspace for Xin Ren at the University of Bristol. It contains scripts, data, documentation, and meeting notes for emulating the HadCM3 climate model over 1 Ma timescales to assess future climate at UK nuclear waste repository sites.

The core ML emulator package lives in a **separate** repository at `~/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/paleo-emu/` — see `toClaude/CLAUDE.md` there for code architecture details.

## Repository Structure

```
NWS_emulation/           # Main working directory for running emulations
  prediction/            # Scripts and configs for making predictions
    run_prediction.py    # Entry point to train models and generate predictions
    prediction.yml       # Master config (paths, model params, forcing scenarios)
    saved_models/        # Trained .joblib artifacts (PCA + GP models)
    results_nc/          # Raw NetCDF prediction outputs
    results_on_sites/    # Site-extracted prediction outputs
    plot+scripts/        # Jupyter notebooks for analysis and plotting
  emulator_validation/
    paleo-emu-LOO/       # Leave-one-out validation scripts and results
    validation.py        # Cartopy-based map visualisation of predictions vs truth
  training_data/         # X (.res) and Y (.nc) training arrays for both ice states
  UK_site_data/          # Scripts to extract predictions at 112 UK repository sites
  other_plot/            # Orbital parameter plots
NWS_RSO_report_2026/     # Deliverable report plots and reviewer comments
NWS-meetings/            # Meeting notes and shared data (Quintessa input files)
reports/                 # Reference PDFs (TR-19-09, etc.)
```

## End-to-End Prediction Workflow

The full workflow (documented in `NWS_emulation/Emulation_detailed_workflow.md`) runs in three stages, each in a different directory:

**Stage 1 – Emission scenarios & CO₂ model**
Notebooks live in `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/CO2_calculation/`:
1. `Create_SSP_emissions.ipynb` / `create_10000GtC_emission.ipynb`
2. `Convoluted_response_function.ipynb`
3. `make_CO2_ppmv_data_in_ka.ipynb`

**Stage 2 – GSL model & updated CO₂**
MATLAB scripts + notebooks in `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/`:
1. Run `Archer_Ganopolski_2005_rcp_4_1myrAP_LHC_sens_test_atka_Xin.m`
2. Run `plot_Figure3_4a_Xin.m`
3. Run `inputX/orig/Create_Samp_SSP_upd_1myr_AP.ipynb`
4. Run `updated_CO2_from_RSL_rcp_4_1myrAP_from800kyrBP_RCP_LHC_Xin.m`
5. Run `update_CO2_LHC_members.ipynb`

**Stage 3 – Emulator training & prediction**
`NWS_emulation/prediction/run_prediction.py` is the entry point:

```bash
cd NWS_emulation/prediction
# Activate the paleo-emu environment first:
conda activate paleo-emu
# Or using the local venv:
source ../../../TONIC-Oligocene/paleo-emu/.venv/bin/activate

# Train all variables for one ice state and run predictions:
python run_prediction.py
```

The two ice states are `modhighice` and `modlowice`. Ten climate variables are emulated:
`tas`, `precip`, `evap`, `windspeed`, `ice_sheet`, `iceconc`, `LAI_PFT`, `snowdepth`, `sm`, `soiltemp`.

## Configuration

`prediction.yml` (in `NWS_emulation/prediction/`) controls all paths and model settings.

Key fields:
- `training_file_path` — points to `training_data/` directory (absolute path)
- `X_input_file_name` — whitespace-delimited `.res` file with 5 forcing columns: `co2, obliquity, esinw, ecosw, ice`
- `Y_input_file_name` — NetCDF file of flattened spatial fields `(n_samples, n_lat × n_lon)`
- `forcing_data_path` — path to scenario inputs from the GSL model (Stage 2 outputs)
- `encoder_config.encoder_type` — `PCA` (default) or `VAE`
- `regressor_config.kernels` — list from `["RBF", "Matern_nu_15", "Matern_nu_25"]`

`override_params` can be passed at runtime in `run_prediction.py` to change `model_run_name`, `X_input_file_name`, `Y_input_file_name`, or `forcing_data` without editing the YAML.

## Prediction Outputs

Predictions are saved as NetCDF to `/Volumes/Xin-data/result/` (external drive). Each file is named:
`{model_run_name}_{scenario}_{member}_predictions.nc`

It contains two variables: the predicted field and `std` (uncertainty, from GP variance propagation through PCA).

## Validation

**LOO validation**: scripts in `emulator_validation/paleo-emu-LOO/`. Run `LOO_emulation_loop.py` which calls `LOO_emulation.py` per held-out experiment. RMSE results are in `.res` files there.

**10-fold CV**: integrated in `run_prediction.py` via `_run_training_test_with_cfg()` — checks hold-out R² > 0.95 before full training.

**Performance criterion**: Hold-out R² must exceed 0.95 for an emulator to be accepted.

## Site Data Extraction

After generating global NetCDF predictions, extract values at 112 UK repository sites using:
- `UK_site_data/get_data_for_each_site.ipynb`
- `prediction/plot+scripts/Make_site_txt.py`

Site indices into the HadCM3 grid are pre-computed in `UK_site_data/`.

## paleo-emu Package (External Dependency)

The `paleo_emu` Python package must be installed from `TONIC-Oligocene/paleo-emu/`:

```bash
cd ~/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/paleo-emu
pip install -e .
```

The package API used here:
- `paleo_emu.config.load_config(path)` — load and validate YAML into `PaleoEmuConfig`
- `paleo_emu.load.load_training_data(cfg)` — returns `X, Y, ..., lat_array, lon_array`
- `paleo_emu.load.load_forcing_data(cfg, scenario=...)` — returns scenario DataFrame
- `paleo_emu.training.TrainingGenerator` — fits GridSearchCV, saves `.joblib` artifact
- `paleo_emu.regressor.EncodedTargetRegressor.predict_with_variance(X)` — returns mean + std

## Code Modification Rules

1. **Never modify existing code without backing it up first.** Before editing any `.py`, `.ipynb`, `.m`, or `.yml` file, copy it to a backup named `{original_name}_backup_{YYYYMMDD}` in the same directory.

2. **All new files created by Claude must be prefixed with `CC_`.** This applies to new `.py` scripts, new `.ipynb` notebooks, new `.yml` configs, and any other new code files. Example: a new plotting script should be named `CC_plot_ice_sheet_4regime.py`, not `plot_ice_sheet_4regime.py`. This prefix distinguishes Claude-generated code from Xin's own code.

3. These two rules apply to all tasks in `toClaude/tasks.md`.

## Work Progress Tracker

See the Google Sheet linked in `NWS_emulation/NWS-RSO-work.md` for current task status. The Obsidian vault (`.obsidian/`) is used for local notes; `NWS_emulation/NWS-RSO-work.md` is the central note linking tasks to code.
