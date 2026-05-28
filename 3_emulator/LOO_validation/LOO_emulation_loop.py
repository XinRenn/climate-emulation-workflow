import os
from pathlib import Path
import unittest

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


class TestTraining(unittest.TestCase):
    def setUp(self):
        # Directory of this test file: .../tests
        here = Path(__file__).resolve().parent

        # Use the repo root as the directory containing this file
        self.repo_root = here

        # Path to training_data alongside this test file
        self.examples_dir = here / "training_data"

        # Path to prediction_data alongside this test file
        self.prediction_dir = here / "prediction_data"

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

        # 80/20 train–test split for performance evaluation
        X_train, X_test, Y_train, Y_test = train_test_split(
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
        self.assertTrue(os.path.exists(artifact_path))

        # Return everything needed for checks
        return artifact_path, X_full, X_test, Y_test

    def _check_artifact_and_predictions(self, artifact_path, X_full, X_test, Y_test):
        # Load the artifact
        artifact = joblib.load(artifact_path)

        # Basic keys check
        self.assertIn("model", artifact)
        model = artifact["model"]

        # Model should be an EncodedTargetRegressor
        self.assertIsInstance(model, EncodedTargetRegressor)

        # -------------------------------------------------
        # 1) Mean value check on original X field
        # -------------------------------------------------
        Y_pred_full = model.predict(X_full)
        field_mean = np.mean(Y_pred_full)
        self.assertAlmostEqual(field_mean, 5.3, delta=0.05)
        print(f"Mean temperature: {field_mean}")

        # -------------------------------------------------
        # 2) Performance check on 20% hold-out set
        # -------------------------------------------------
        Y_pred_test = model.predict(X_test)

        # R^2 averaged over all outputs
        r2 = r2_score(Y_test, Y_pred_test, multioutput="uniform_average")

        print(f"Hold-out R^2: {r2}")

        self.assertGreater(
            r2,
            0.99,
            msg=f"Hold-out R^2 too low: {r2}",
        )

    def _run_prediction_with_cfg(self, cfg_filename: str, scenario:str, override_params: dict = None):
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
        self.assertTrue(os.path.exists(artifact_path))
        artifact = joblib.load(artifact_path)

        model = artifact["model"]
        self.assertIsInstance(model, EncodedTargetRegressor)

        # Make predictions
        X_pred = load_forcing_data(cfg, scenario=scenario)
        Y_pred = model.predict(X_pred)
        Y_pred = Y_pred[::-1,:] # flip latitudes if needed

        print(f"[DEBUG] X_pred values: {X_pred.iloc[:5,:] if hasattr(X_pred, 'iloc') else X_pred[:5,:]}")

        # save predictions for as NetCDF
        lat_array = artifact["lat_array"]
        lon_array = artifact["lon_array"]
        var_name = artifact.get("var_name", "temperature")
        output_ds = xr.Dataset(
            {
                var_name: (("time", "lat", "lon"), Y_pred.reshape(-1, len(lat_array), len(lon_array)))
            },
            coords={
                "time": np.arange(Y_pred.shape[0]),
                "lat": lat_array,
                "lon": lon_array,
            }
        )
        output_path = self.prediction_dir / f"{cfg.model_run_name}_predictions.nc"
        output_ds.to_netcdf(output_path)
        print(f"Predictions saved to {output_path}")

        return Y_pred
    

    def test_run_training_pca_gp(self): 
        # Full training run using PCA encoder config with 10% hold-out performance check.
        for i in range(90,122):
            custom_params = {
                "model_run_name": f"{i}case_LOO_emulation_modhighice",
                "X_input_file_name": f"emul_in_X_train_modhigh_{i}.res",
                "Y_input_file_name": f"emul_in_Y_train_modhigh_{i}.nc",
                "forcing_data": {
                    f"0case": {
                        "forcing_input": f"emul_in_X_modhigh_{i}.res"
                    }
                }
            }
            
            artifact_path, X_full, X_test, Y_test = self._run_training_with_cfg(
                "LOO_emulation.yml", 
                override_params=custom_params
            )
            print(f"[DEBUG] first value of X_full for i={i}: {X_full[0,:]}")
            # Optionally check artifact and predictions
            # self._check_artifact_and_predictions(artifact_path, X_full, X_test, Y_test)
            Y_pred = self._run_prediction_with_cfg(
                "LOO_emulation.yml", 
                scenario=f"0case", 
                override_params=custom_params
            )



if __name__ == "__main__":
    unittest.main(verbosity=2)
