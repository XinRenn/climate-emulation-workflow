import os
from pathlib import Path

import joblib
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score

from paleo_emu.training import TrainingGenerator
from paleo_emu.config import load_config
from paleo_emu.load import load_training_data
from paleo_emu.load import load_forcing_data
from paleo_emu.regressor import EncodedTargetRegressor  
import xarray as xr
import time


class PredictionRunner:
    def __init__(self):
        # Directory of this script
        here = Path(__file__).resolve().parent

        # Use the repo root as the directory containing this file
        self.repo_root = here

        # Path to training_data alongside this script
        self.examples_dir = here / "saved_models"

        # Path to prediction_data alongside this script
        # self.prediction_dir = here / "results"
        self.prediction_dir = Path("/Volumes/Xin-data/result")

    def _run_training_with_cfg(self, cfg_filename: str, override_params: dict = None):
        model_cfg_path = self.repo_root / cfg_filename

        # Use the typed loader (PaleoEmuConfig)
        cfg = load_config(str(model_cfg_path))
        
        # Manual override of config parameters
        if override_params:
            for key, value in override_params.items():
                if hasattr(cfg, key):
                    setattr(cfg, key, value)
                    print(f"[OVERRIDE] {key} = {value}")
                else:
                    print(f"[WARNING] Config has no attribute '{key}'")

        # Load full training data from disk
        X_full, Y_full, _, _, lat_array, lon_array = load_training_data(cfg)

        # Handle NaN in Y - remove features that are ALWAYS NaN (land regions)
        # Keep the grid structure intact (73 x 96) for spatial coherence
        always_nan_mask = None
        if np.isnan(Y_full).any():
            nan_count = np.isnan(Y_full).sum()
            total_count = Y_full.size
            nan_pct = 100 * nan_count / total_count
            print(f"[WARNING] Y_full contains {nan_count}/{total_count} ({nan_pct:.1f}%) NaN values.")
            
            # Identify features (grid points) that are ALWAYS NaN across ALL time steps
            # These represent land regions where the variable is never defined
            always_nan_mask = np.all(np.isnan(Y_full), axis=0)
            n_always_nan = always_nan_mask.sum()
            
            if n_always_nan > 0:
                print(f"[INFO] Found {n_always_nan} always-NaN features (land/invalid regions)")
                # Remove completely invalid features for training
                Y_full = Y_full[:, ~always_nan_mask]
                # For remaining partial NaN (ocean points with occasional missing data), fill with 0
                # This is physically meaningful for sea ice: 0 = no ice
                Y_full = np.nan_to_num(Y_full, nan=0.0)
                print(f"[INFO] Kept {Y_full.shape[1]} valid features, filled partial NaN with 0.0")

        training = TrainingGenerator(
            cfg,
            X_full,
            Y_full,
            lat_array,
            lon_array,
            output_dir=str(self.examples_dir),
        )
        artifact_path = training.run_training()
        assert os.path.exists(artifact_path), f"Artifact not found: {artifact_path}"

        # Persist mask information for reconstruction during prediction
        if always_nan_mask is not None:
            artifact = joblib.load(artifact_path)
            artifact["always_nan_mask"] = always_nan_mask
            artifact["total_grid_size"] = always_nan_mask.shape[0]
            joblib.dump(artifact, artifact_path)

        # Return everything needed for checks
        return artifact_path, X_full

    def _run_training_test_with_cfg(self, cfg_filename: str, override_params: dict = None):
        model_cfg_path = self.repo_root / cfg_filename

        # Use the typed loader (PaleoEmuConfig)
        cfg = load_config(str(model_cfg_path))
        
        # Manual override of config parameters
        if override_params:
            for key, value in override_params.items():
                if hasattr(cfg, key):
                    setattr(cfg, key, value)
                    print(f"[OVERRIDE] {key} = {value}")
                else:
                    print(f"[WARNING] Config has no attribute '{key}'")

        # Load full training data from disk
        X_full, Y_full, _, _, lat_array, lon_array = load_training_data(cfg)

        # Handle NaN in Y - remove features that are ALWAYS NaN (land regions)
        # Keep the grid structure intact (73 x 96) for spatial coherence
        always_nan_mask = None
        if np.isnan(Y_full).any():
            nan_count = np.isnan(Y_full).sum()
            total_count = Y_full.size
            nan_pct = 100 * nan_count / total_count
            print(f"[WARNING] Y_full contains {nan_count}/{total_count} ({nan_pct:.1f}%) NaN values.")
            
            # Identify features (grid points) that are ALWAYS NaN across ALL time steps
            # These represent land regions where the variable is never defined
            always_nan_mask = np.all(np.isnan(Y_full), axis=0)
            n_always_nan = always_nan_mask.sum()
            
            if n_always_nan > 0:
                print(f"[INFO] Found {n_always_nan} always-NaN features (land/ocean/invalid regions)")
                # Remove completely invalid features for training
                Y_full = Y_full[:, ~always_nan_mask]
                # For remaining partial NaN (ocean points with occasional missing data), fill with 0
                # This is physically meaningful for sea ice: 0 = no ice
                nan_count_before = np.isnan(Y_full).sum()
                Y_full = np.nan_to_num(Y_full, nan=0.0)
                print(f"[INFO] Kept {Y_full.shape[1]} valid features, filled {nan_count_before} NaN values with 0.0")
            
        
        # 80/20 train–test split for performance evaluation
        X_train, X_test, Y_train, Y_test_raw = train_test_split(
            X_full,
            Y_full,
            test_size=0.1,
            random_state=cfg.random_state,
        )

        training = TrainingGenerator(
            cfg,
            X_train,
            Y_train,
            lat_array,
            lon_array,
            output_dir=str(self.examples_dir),
        )
        artifact_path = training.run_training()
        assert os.path.exists(artifact_path), f"Artifact not found: {artifact_path}"

        # Persist mask information for reconstruction during prediction
        if always_nan_mask is not None:
            artifact = joblib.load(artifact_path)
            artifact["always_nan_mask"] = always_nan_mask
            artifact["total_grid_size"] = always_nan_mask.shape[0]
            joblib.dump(artifact, artifact_path)
            print("[INFO] Saved always_nan_mask to artifact for prediction reconstruction.")
            Y_test_unmasked = np.full((Y_test_raw.shape[0],always_nan_mask.shape[0]),np.nan)
            Y_test_unmasked[:,~always_nan_mask] = Y_test_raw
            Y_test = Y_test_unmasked
        else:
            Y_test = Y_test_raw

        # Return everything needed for checks
        return artifact_path, X_full, X_test, Y_test

    def _check_artifact_and_predictions(self, artifact_path, X_full, X_test, Y_test):
        # Load the artifact
        artifact = joblib.load(artifact_path)

        # Basic keys check
        assert "model" in artifact, "Model not found in artifact"
        model = artifact["model"]

        # Model should be an EncodedTargetRegressor
        assert isinstance(model, EncodedTargetRegressor), "Model is not EncodedTargetRegressor"

        # -------------------------------------------------
        # 1) Mean value check on original X field
        # -------------------------------------------------
        Y_pred_full = model.predict(X_full)
        field_mean = np.mean(Y_pred_full)
        print(f"Mean temperature: {field_mean}")

        # -------------------------------------------------
        # 2) Performance check on 20% hold-out set
        # -------------------------------------------------
        # Retrieve mask for reconstruction (if present)
        always_nan_mask = artifact.get("always_nan_mask", None)
        total_grid_size = artifact.get("total_grid_size", None)

        # Make predictions on masked features (model was trained on 2381 features)
        Y_pred_masked = model.predict(X_test)

        # Reconstruct full grid with NaN in masked locations (2381 -> 7008)
        if always_nan_mask is not None and total_grid_size is not None:
            Y_pred_full = np.full((Y_pred_masked.shape[0], total_grid_size), np.nan)
            Y_pred_full[:, ~always_nan_mask] = Y_pred_masked
            Y_pred_test = Y_pred_full
        else:
            Y_pred_test = Y_pred_masked

        print(f"valid Y_test number: {np.sum(~np.isnan(Y_test))}, shape: {Y_test.shape}")
        print(f"valid Y_pred_test number: {np.sum(~np.isnan(Y_pred_test))}, shape: {Y_pred_test.shape}")
        
        # R² should ONLY be calculated on valid (non-NaN) features
        # Both Y_test and Y_pred_test should have NaN in the same masked locations
        valid_mask = ~np.isnan(Y_test)
        if not np.array_equal(valid_mask, ~np.isnan(Y_pred_test)):
            print("[WARNING] Y_test and Y_pred_test have different NaN patterns!")
        
        # Flatten and filter
        Y_test_valid = Y_test[valid_mask]
        Y_pred_valid = Y_pred_test[valid_mask]
        
        print(f"[INFO] Computing R² on {valid_mask.sum()} valid samples")
        
        # R^2 averaged over all outputs
        r2 = r2_score(Y_test_valid, Y_pred_valid)

        print(f"Hold-out R^2: {r2}")
        assert r2 > 0.95, f"Hold-out R^2 too low: {r2}"

    def _run_prediction_with_cfg(self, cfg_filename: str, scenario: str, member: int = None, override_params: dict = None):
        model_cfg_path = self.repo_root / cfg_filename

        # Use the typed loader (PaleoEmuConfig)
        cfg = load_config(str(model_cfg_path))

        if override_params:
            for key, value in override_params.items():
                if hasattr(cfg, key):
                    setattr(cfg, key, value)
                    print(f"[OVERRIDE] {key} = {value}")
                else:
                    print(f"[WARNING] Config has no attribute '{key}'")

        # Load the trained model artifact
        artifact_path = self.examples_dir / f"{cfg.model_run_name}_fitted_pipeline.joblib"
        if not os.path.exists(artifact_path):
            raise FileNotFoundError(f"Artifact not found: {artifact_path}")
        artifact = joblib.load(artifact_path)

        model = artifact["model"]
        assert isinstance(model, EncodedTargetRegressor), "Model is not EncodedTargetRegressor"

        # Retrieve mask for reconstruction (if present)
        always_nan_mask = artifact.get("always_nan_mask", None)
        total_grid_size = artifact.get("total_grid_size", None)

        # Make predictions
        X_pred = load_forcing_data(cfg, scenario=scenario)

        Y_pred_masked, Y_std_masked = model.predict_with_variance(X_pred.to_numpy())
        # Do NOT flip time axis - keep temporal order as-is

        # Reconstruct full grid with NaN in masked locations
        if always_nan_mask is not None and total_grid_size is not None:
            print(f'[INFO] There is a NaN mask in this variable.')
            Y_full = np.full((Y_pred_masked.shape[0], total_grid_size), np.nan)
            Y_full_std = np.full((Y_std_masked.shape[0], total_grid_size), np.nan)
            Y_full[:, ~always_nan_mask] = Y_pred_masked
            Y_full_std[:, ~always_nan_mask] = Y_std_masked
            Y_pred = Y_full
            Y_std = Y_full_std
        else:
            Y_pred = Y_pred_masked
            Y_std = Y_std_masked

        print(f"[DEBUG] X_pred values: {X_pred.iloc[:5,:] if hasattr(X_pred, 'iloc') else X_pred[:5,:]}")

        # save predictions for as NetCDF
        lat_array = artifact["lat_array"]
        lon_array = artifact["lon_array"]
        expected_size = len(lat_array) * len(lon_array)
        assert Y_pred.shape[1] == expected_size, (
            f"Prediction feature size {Y_pred.shape[1]} does not match grid {expected_size}. "
            "Check always_nan_mask and grid dimensions."
        )
        var_name = artifact.get("var_name", "var")
        output_ds = xr.Dataset(
            {
                var_name: (("time", "lat", "lon"), Y_pred.reshape(-1, len(lat_array), len(lon_array))),
                "std": (("time", "lat", "lon"), Y_std.reshape(-1, len(lat_array), len(lon_array))),
            },
            coords={
                "time": np.arange(Y_pred.shape[0]),
                "lat": lat_array,
                "lon": lon_array,
            }
        )
        # Build output filename with member if provided
        fname = f"{cfg.model_run_name}_{scenario}" + (f"_{member}" if member is not None else "") + "_predictions.nc"
        output_path = self.prediction_dir / fname
        output_ds.to_netcdf(output_path)
        print(f"Predictions saved to {output_path}")

        return Y_pred, Y_std
    
    def _test_run_training_pca_gp(self): 
        # """Full training run using PCA encoder config with 10% hold-out performance check."""
        artifact_path, X_full, X_test, Y_test = self._run_training_with_cfg("prediction_tas.yml")
        self._check_artifact_and_predictions(artifact_path, X_full, X_test, Y_test)
        Y_pred, Y_std = self._run_prediction_with_cfg("prediction_tas.yml", scenario="4case")

    def run_training_pca_gp_Allvar(self,vars=None,state="modhighice"): 
        """Full training run using PCA encoder config with 10% hold-out performance check."""
                # Full training run using PCA encoder config with 10% hold-out performance check.
        if vars is None:
            vars=["tas","precip","evap","windspeed","ice_sheet","iceconc","LAI_PFT","snowdepth","sm","soiltemp"]
        for var in vars:
            custom_params = {
                "model_run_name": f"{var}_{state}",
                "X_input_file_name": f"emul_in_X_{state}.res",
                "Y_input_file_name": f"emul_in_Y_{state}_{var}.nc"
            }
            print(f"================================================================================")
            print(f"Performing check first using 10% hold-out set... for variable: {var}")
            print(f"================================================================================")
            artifact_path, X_full, X_test, Y_test = self._run_training_test_with_cfg(
                "prediction.yml", 
                override_params=custom_params
            )
            print(f"[DEBUG] first value of X_full for var={var}: {X_full[0,:]}")
            # Optionally check artifact and predictions
            self._check_artifact_and_predictions(artifact_path, X_full, X_test, Y_test)

            print(f"================================================================================")
            print(f"Running training for variable: {var}")
            print(f"================================================================================")
            artifact_path, X_full, X_test, Y_test = self._run_training_test_with_cfg(
                "prediction.yml", 
                override_params=custom_params
            )
    
    def run_prediction_pca_gp_Allvar_Allmembers(self,vars=None,state="modhighice"):
        if vars is None:
            vars=["tas","precip","evap","windspeed","ice_sheet","iceconc","LAI_PFT","snowdepth","sm","soiltemp"]
        scenarios=["10000PGC"]
        # scenarios=["natural","SSP126","SSP245","SSP370","SSP460","SSP534","SSP585"]
        members = range(1,91)
        for var in vars:
            for scenario in scenarios:
                for member in members:
                    custom_params = {
                        "model_run_name": f"{var}_{state}",
                        "forcing_data": {
                            f"{scenario}": {
                                "forcing_input": f"emul_inputs_{scenario}.{member}.updated.res"
                            }
                        }
                    }
                    Y_pred, Y_std = self._run_prediction_with_cfg("prediction.yml", scenario=scenario, member=member, override_params=custom_params)

if __name__ == "__main__":
    # Create runner instance
    runner = PredictionRunner()
    # Run training for all variables
    print("=" * 80)
    print("Starting training for all variables...")
    print("=" * 80)
    start_time = time.time()
    # runner.run_training_pca_gp_Allvar(vars=["tas","precip"],state="modlowice")
    runner.run_prediction_pca_gp_Allvar_Allmembers(vars=["sm","soiltemp"],state="modlowice")
    runner.run_prediction_pca_gp_Allvar_Allmembers(vars=["evap","windspeed","ice_sheet","iceconc","LAI_PFT","snowdepth","sm","soiltemp"],state="modhighice")
    elapsed_time = time.time() - start_time
    print("=" * 80)
    print(f"All prediction completed! Total time: {elapsed_time:.2f} seconds ({elapsed_time/60:.2f} minutes)")
    print("=" * 80)

#