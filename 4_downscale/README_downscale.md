# NWS Downscaling — UK Regional Prediction

This directory contains the high-resolution PCA+GP emulator workflow for predicting UK-region climate variables under palaeo and future forcing scenarios.

## Downscaling strategy

Producing high-resolution downscaled climate across the full 1-million-year ensemble is computationally demanding. Five strategies were considered:

| Scheme | Description | Feasibility |
|--------|-------------|-------------|
| 1 | Emulate all 10 variables globally (72×96), then downscale | ✗ Compute cost ~130× baseline for emulation; downscaling cost ~540,000× baseline |
| 2 | Emulate all variables globally, clip to UK, downscale UK region | ⚠ Theoretically feasible but regional CHELSA modification introduces bias |
| 3 | **Downscale HadCM3 training data first, then emulate high-res tas & pr** | ✅ **Chosen** |
| 4 | Downscale training data → extract CHELSA intermediate files (tz, we, lcl, orog) → emulate intermediates (360×720) → run full-globe CHELSA | ⚠ Intermediate files are 360×720, making emulation cost higher than Scheme 3 |
| 5 | Same as Scheme 4 but clip to UK before final CHELSA pass | ⚠ Regional CHELSA modification causes discrepancies vs global output |

**Chosen: Scheme 3.**

The HadCM3 training snapshots (low-ice and high-ice states) are downscaled using CHELSA from the native 72×96 grid to 360×720 (~1 km). The downscaled fields for `tas` and `pr` become the emulator training targets (`emul_in_Y_*.nc`). The emulator then learns to map the 5-dimensional orbital/CO₂/ice forcing directly to high-resolution output, so no downscaling step is needed at prediction time.

**Consequence for training data:** `training_data_highres/emul_in_Y_{state}_{var}.nc` contains CHELSA-downscaled HadCM3 fields, not the raw model output. The corresponding forcing features (`emul_in_X_{state}.res`) are unchanged from the global emulator.

---

## UK-only output export

The global prediction grid is large (~1.5 GB per scenario × member). Saving the full global NetCDF for every ensemble member (90 members × 5 scenarios × 2 variables × 2 ice states = 1800 files) is not practical. Instead, predictions are clipped to the UK bounding box **in memory** before writing to disk, reducing each output file to ~6 MB. No global NetCDF files are written.

UK bounding box: lon `(-11, 4)`, lat `(49, 61)`.

---

## Directory layout

```
downscaling_NWS/
├── ../3_emulator/prediction.yml                  # emulator configuration (see below)
├── run_prediction_saveUK.py        # main script: train + predict + clip to UK
├── run_prediction_highres.sh       # SLURM submission script
│
├── training_data_highres/          # training inputs (not in repo — large files)
│   ├── emul_in_X_modlowice.res     # forcing features, low-ice state
│   ├── emul_in_X_modhighice.res    # forcing features, high-ice state
│   ├── emul_in_Y_modlowice_tas.nc  # target: surface temperature, low-ice
│   ├── emul_in_Y_modlowice_pr.nc   # target: precipitation, low-ice
│   ├── emul_in_Y_modhighice_tas.nc
│   └── emul_in_Y_modhighice_pr.nc
│
├── emul_inputs_updatedCO2/         # scenario forcing files — symlink or copy from
│   │                                # 2_GSL_model/results/emul_inputs_updatedCO2/
│   ├── emul_inputs_10000PGC.{1..90}.updated.res
│   ├── emul_inputs_SSP126.{1..90}.updated.res
│   ├── emul_inputs_SSP245.{1..90}.updated.res
│   ├── emul_inputs_SSP370.{1..90}.updated.res
│   ├── emul_inputs_SSP585.{1..90}.updated.res
│   └── emul_inputs_natural.{1..90}.updated.res
│
├── trained_pipeline_highres/       # saved model artifacts (auto-generated)
│   └── {var}_{state}_highres_fitted_pipeline.joblib
│
├── results_highres_uk/             # prediction outputs (auto-generated)
│   └── {var}_{state}_highres_{scenario}_{member}_UK.nc
│
└── log/                            # SLURM stdout/stderr logs
```

---

## Configuration: `prediction.yml`

Key fields:

| Field | Description |
|---|---|
| `training_file_path` | Directory containing `emul_in_X_*.res` and `emul_in_Y_*.nc` |
| `forcing_data_path` | Directory containing `emul_inputs_*.res` files |
| `output_dir` | Where trained `.joblib` artifacts are saved |
| `encoder_config` | PCA encoder — `n_components` or `pca_variance_ratio` |
| `regressor_config` | GP regressor — kernel choices and optimizer restarts |
| `forcing_data` | One entry per scenario, each with a pattern over ensemble members |

The script overrides `training_file_path`, `output_dir`, `model_run_name`, `X_input_file_name`, and `Y_input_file_name` at runtime for each `(variable, ice_state)` combination, so the YAML defaults are largely ignored.

---

## Workflow

```
For each (variable, ice_state):
    1. Train PCA+GP emulator on full training data  →  saves .joblib artifact
    2. For each scenario:
           For each ensemble member (1–90):
               Load forcing file  →  predict (mean + variance)  →  clip to UK  →  save .nc
```

The training step is the bottleneck (~90 s per variable×state combination on a 4-core node). Prediction is ~55 s per member. Full run for both variables and both ice states takes approximately **27 hours** in serial.

### Recommended: split by (variable, ice_state)

Submit 4 parallel SLURM jobs (one per combination), each requesting ~8 hours:

| Job | Variable | Ice state | Approx. wall time |
|-----|----------|-----------|------------------|
| 1 | `tas` | `modlowice` | ~7 h |
| 2 | `tas` | `modhighice` | ~7 h |
| 3 | `pr` | `modlowice` | ~7 h |
| 4 | `pr` | `modhighice` | ~7 h |

---

## Running on a SLURM cluster

1. Activate the conda environment that contains `paleo_emu`, `xarray`, `joblib`, `scikit-learn`, and `numpy`.

2. Make a shell script to submit the python script on slurm

3. Update the paths in `prediction.yml` to match your local directory layout:
   - `training_file_path` → path to `training_data_highres/`
   - `forcing_data_path` → path to `emul_inputs_updatedCO2/` (or use the copy in `2_GSL_model/results/emul_inputs_updatedCO2/`)

4. To run the full pipeline for all variables and ice states in one job:
   ```bash
   sbatch run_prediction_highres.sh
   ```

5. To check progress, tail the log:
   ```bash
   tail -f log/prediction_<jobid>.out
   ```

---

## Output format

Each output file covers one `(variable, ice_state, scenario, member)` combination:

```
{var}_{state}_highres_{scenario}_{member}_UK.nc
```

Example: `tas_modlowice_highres_SSP585_42_UK.nc`

Variables inside each NetCDF:

| Variable | Dimensions | Description |
|----------|------------|-------------|
| `tas` / `pr` | `(time, lat, lon)` | Predicted climate field (emulator mean) |
| `var` | `(time, lat, lon)` | Prediction variance (GP posterior) |

Coordinates: `time` is a zero-based integer index over the 1001-member forcing time steps; `lat` and `lon` are the emulator's native grid within the UK box.

Disk usage: ~6 MB per file × 1800 files = **~10 GB** for the full ensemble.

---

## Dependencies

- [`paleo_emu`](https://github.com/paleo-emu-model/paleo-emu) — PCA+GP emulator library
- `xarray`, `numpy`, `joblib`, `scikit-learn`
- Python ≥ 3.8
