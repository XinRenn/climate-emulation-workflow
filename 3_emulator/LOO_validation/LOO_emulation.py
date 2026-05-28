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

    def _run_training_with_cfg(self, cfg_filename: str):
        model_cfg_path = self.repo_root / cfg_filename

        # Use the typed loader (PaleoEmuConfig)
        cfg = load_config(str(model_cfg_path))

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

    def _run_prediction_with_cfg(self, cfg_filename: str, scenario:str):
        model_cfg_path = self.repo_root / cfg_filename

        # Use the typed loader (PaleoEmuConfig)
        cfg = load_config(str(model_cfg_path))

        # Load the trained model artifact
        artifact_path = self.examples_dir / f"{cfg.model_run_name}_fitted_pipeline.joblib"
        self.assertTrue(os.path.exists(artifact_path))
        artifact = joblib.load(artifact_path)

        model = artifact["model"]
        self.assertIsInstance(model, EncodedTargetRegressor)

        # Make predictions
        X_pred = load_forcing_data(cfg, scenario=scenario)
        print(f"first value of X_pred: {X_pred.iloc[0,:].values if hasattr(X_pred, 'iloc') else X_pred[0,:]}")

        Y_pred = model.predict(X_pred)
        Y_pred = Y_pred[::-1,:] # flip latitudes if needed

        print(f"[DEBUG] mean of Y_pred: {np.mean(Y_pred)}")

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
        # """Full training run using PCA encoder config with 10% hold-out performance check."""
        artifact_path, X_full, X_test, Y_test = self._run_training_with_cfg("LOO_emulation.yml")
        self._check_artifact_and_predictions(artifact_path, X_full, X_test, Y_test)
        Y_pred = self._run_prediction_with_cfg("LOO_emulation.yml", scenario="4case")

    # def test_run_training_pca_xgb(self):
    #     """Full training run using PCA encoder config with 10% hold-out performance check."""
    #     artifact_path, X_full, X_test, Y_test = self._run_training_with_cfg("test_PCA_XGB.yml")
    #     self._check_artifact_and_predictions(artifact_path, X_full, X_test, Y_test)


    # def test_run_training_vae(self):
    #     """Full training run using VAE (learned encoder) config with 10% hold-out performance check."""
    #     artifact_path, X_full, X_test, Y_test = self._run_training_with_cfg("test_VAE.yml")
    #     self._check_artifact_and_predictions(artifact_path, X_full, X_test, Y_test)


if __name__ == "__main__":
    unittest.main(verbosity=2)
