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

NetCDF predictions saved to `/Volumes/Xin-data/result/` (external drive):
`{model_run_name}_{scenario}_{member}_predictions.nc`

Each file contains the predicted field and `std` (GP uncertainty).

## LOO Validation

Scripts in `LOO_validation/`. Run `LOO_emulation_loop.py` which calls `LOO_emulation.py` per held-out experiment.

Performance criterion: hold-out R² > 0.95.

## Site Extraction

After generating global NetCDF predictions, extract values at 112 UK repository sites using:
- `UK_site_data/get_data_for_each_site.ipynb`
- `4_plots/Make_site_txt.py`

Site indices into the HadCM3 grid are pre-computed in `UK_site_data/UK_sites_index.res`.