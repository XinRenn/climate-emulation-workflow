# Stage 3 — Emulator: Server Setup

The emulator training and prediction step runs on the Bristol HPC or a remote server.

## Environment

```bash
conda activate paleo-emu
# or using the local venv:
source ../../../TONIC-Oligocene/paleo-emu/.venv/bin/activate
```

The `paleo_emu` package must be installed from `TONIC-Oligocene/paleo-emu/`:

```bash
cd ~/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/paleo-emu
pip install -e .
```

## Running predictions

```bash
cd 3_emulator/
python run_prediction.py
```

Edit `prediction.yml` to set paths and model parameters before running.

## Key config fields (`prediction.yml`)

| Field | Description |
|-------|-------------|
| `training_file_path` | Path to `training_data/` |
| `X_input_file_name` | `.res` file with 5 forcing columns: `co2, obliquity, esinw, ecosw, ice` |
| `Y_input_file_name` | NetCDF of flattened spatial fields `(n_samples, n_lat × n_lon)` |
| `forcing_data_path` | Stage 2 outputs (`emul_inputs_{scenario}.{member}.updated.res`) |
| `encoder_config.encoder_type` | `PCA` (default) or `VAE` |
| `regressor_config.kernels` | `["RBF", "Matern_nu_15", "Matern_nu_25"]` |

## Outputs

NetCDF predictions saved to the server `outputs/` directory, then pulled locally by the rsync daemon to `/Volumes/Xin-data/NWS_outputs/`:

```
{var}_{state}_{scenario}_{member}_prediction.nc
```

Example: `tas_modhighice_SSP585_42_prediction.nc`

Each file contains two fields: `var` (emulator mean) and `var_std` (GP posterior uncertainty).

> **Note on PCA config:** `prediction.yml` has both `n_components` and `pca_variance_ratio`. When `pca_variance_ratio` is set, it takes priority over `n_components` — use only one field to avoid ambiguity.

## LOO Validation

Scripts in `LOO_validation/`. Run `LOO_emulation_loop.py` which calls `LOO_emulation.py` per held-out experiment.

Performance criterion: hold-out R² > 0.95.

## Site Extraction (low-resolution)

After the rsync daemon pulls prediction files to `/Volumes/Xin-data/NWS_outputs/`, extract values at 6 UK HadCM3 grid points locally:

```bash
cd 5_plots/
python Run1_extract_uk_sites.py
```

Output: `5_plots/site_data/lowres_results/{var}_{scenario}_site_{site}.txt`  
Site indices: `UK_site_data/UK_sites_index.res`