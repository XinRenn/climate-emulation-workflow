"""
Train highres PCA+GP emulator and predict UK-region climate under paleo forcings.
Uses PaleoEmuRunner API. Predictions are clipped to the UK box in memory;
no global netCDF files are written to disk.
"""
import joblib
import numpy as np
import xarray as xr
from pathlib import Path
import time

from paleo_emu.runner import PaleoEmuRunner, _expand_scenario
from paleo_emu.load import load_forcing_data

HERE = Path(__file__).resolve().parent

UK_LON = (-11, 4)
UK_LAT = (49, 61)

UK_DIR = HERE / "results_highres_uk"


def predict_uk(runner: PaleoEmuRunner, scenario: str, uk_dir: Path) -> None:
    """Predict one scenario, clip to UK box in memory, save UK-only netCDFs."""
    uk_dir.mkdir(parents=True, exist_ok=True)

    artifact  = joblib.load(runner._artifact_path())
    model     = artifact["model"]
    lat_array = artifact["lat_array"]
    lon_array = artifact["lon_array"]
    var_name  = artifact.get("var_name", "var")
    n_lat, n_lon = len(lat_array), len(lon_array)

    scenario_cfg = runner.cfg.forcing_data[scenario]
    for sweep_vals, forcing_file in _expand_scenario(scenario_cfg):
        X_forcing        = load_forcing_data(runner.cfg, forcing_file=forcing_file)
        Y_pred, Y_std    = model.predict_with_variance(X_forcing)
        Y_pred_3d        = Y_pred.reshape(-1, n_lat, n_lon)
        Y_var_3d         = (Y_std ** 2).reshape(-1, n_lat, n_lon) if Y_std is not None else np.zeros_like(Y_pred_3d)

        ds = xr.Dataset(
            {
                var_name: (("time", "lat", "lon"), Y_pred_3d),
                "var":    (("time", "lat", "lon"), Y_var_3d),
            },
            coords={
                "time": np.arange(Y_pred_3d.shape[0]),
                "lat":  lat_array,
                "lon":  lon_array,
            },
        )

        ds_uk = ds.sel(lon=slice(*UK_LON), lat=slice(*UK_LAT))

        sweep_suffix = "_".join(str(v) for v in sweep_vals.values())
        fname = f"{runner.cfg.model_run_name}_{scenario}"
        if sweep_suffix:
            fname += f"_{sweep_suffix}"
        fname += "_UK.nc"

        ds_uk.to_netcdf(uk_dir / fname)
        print(f"  UK saved → {uk_dir / fname}")


if __name__ == "__main__":
    vars_    = ["tas","pr"]
    scenarios = ["10000PGC","SSP126","SSP245","SSP370","SSP585"]
    states   = ["modlowice", "modhighice"]

    UK_DIR.mkdir(parents=True, exist_ok=True)
    start_time = time.time()

    for var in vars_:
        for state in states:
            runner = PaleoEmuRunner("prediction.yml")
            runner.cfg.model_run_name     = f"{var}_{state}_highres"
            runner.cfg.training_file_path = HERE / "training_data_highres"
            runner.cfg.output_dir         = HERE / "trained_pipeline_highres"
            runner.cfg.X_input_file_name  = f"emul_in_X_{state}.res"
            runner.cfg.Y_input_file_name  = f"emul_in_Y_{state}_{var}.nc"

            print(f"\n{'='*60}")
            print(f"Training: {runner.cfg.model_run_name}")
            runner.train()

            for scenario in scenarios:
                print(f"Predicting UK only: {runner.cfg.model_run_name} under {scenario}")
                predict_uk(runner, scenario, UK_DIR)

    elapsed = time.time() - start_time
    print("=" * 80)
    print(f"All completed! Total time: {elapsed:.2f}s ({elapsed/60:.2f} min)")
    print("=" * 80)
