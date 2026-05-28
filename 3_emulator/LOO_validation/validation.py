"""
Example: train an emulator and plot original vs. predicted maps (Cartopy)
=========================================================================

This example shows how to

* load a configuration,
* run a full training using :class:`paleo_emu.training.TrainingGenerator`,
* use the resulting model to predict a target field, and
* plot the original data, the prediction, and their difference
  as three map panels using Cartopy.

The maps use a Plate Carrée projection with coastlines as black lines and a
colorblind-friendly thermal colormap (``inferno``).
"""

from pathlib import Path
import os

import joblib
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split

import cartopy.crs as ccrs
import cartopy.feature as cfeature

from paleo_emu.training import TrainingGenerator
from paleo_emu.config import load_config
from paleo_emu.load import load_training_data

# -------------------------------------------------------------------
# 1. Load configuration and training data
# -------------------------------------------------------------------
here = Path(__file__).resolve().parent
repo_root = here.parent

model_cfg_path = repo_root / "tests" / "test_PCA_GP.yml"
cfg = load_config(str(model_cfg_path))

X_full, Y_full, _, _, lat_array, lon_array = load_training_data(cfg)

X_train, X_test, Y_train, Y_test = train_test_split(
    X_full,
    Y_full,
    test_size=0.2,
    random_state=cfg.random_state,
)

# -------------------------------------------------------------------
# 2. Run training and load the trained model
# -------------------------------------------------------------------
examples_dir = repo_root / "examples"
examples_dir.mkdir(exist_ok=True)

training = TrainingGenerator(
    cfg,
    X_train,
    Y_train,
    lat_array,
    lon_array,
    output_dir=str(examples_dir),
)

artifact_path = training.run_training()

#load trained model
artifact = joblib.load(artifact_path)
model = artifact["model"]

pipe = model.estimator_  # <-- fitted pipeline (NOT model.base_estimator)
mor  = pipe.named_steps["regressor"]  # MultiOutputRegressor

for j, gpr in enumerate(mor.estimators_):  # <-- fitted GPRs live here
    k = gpr.kernel_                        # <-- fitted kernel (NOT gpr.kernel)

    # your kernels are (base + WhiteKernel), so base is k.k1
    print(j, k.k1.length_scale, k.k2.noise_level)

# -------------------------------------------------------------------
# 3. Predict the full field and pick a sample to plot
# -------------------------------------------------------------------
Y_pred_full = model.predict(X_full)

sample_idx = 50
y_true_1d = Y_full[sample_idx]
y_pred_1d = Y_pred_full[sample_idx]

# -------------------------------------------------------------------
# 4. Reshape to (n_lat, n_lon) grids, fix upside-down data
# -------------------------------------------------------------------
n_lat = len(lat_array)
n_lon = len(lon_array)

# First reshape
y_true = y_true_1d.reshape(n_lat, n_lon)
y_pred = y_pred_1d.reshape(n_lat, n_lon)

# The data is stored north→south, but lat_array goes south→north
# Flip the data in latitude, keep lat_array unchanged
y_true = y_true[::-1, :]      # or np.flipud(y_true)
y_pred = y_pred[::-1, :]

y_diff = y_pred - y_true

lon2d, lat2d = np.meshgrid(lon_array, lat_array)


# -------------------------------------------------------------------
# 5. Plot with Cartopy: original, prediction, difference
# -------------------------------------------------------------------
proj = ccrs.PlateCarree()

fig, axes = plt.subplots(
    1,
    3,
    figsize=(18, 4),
    subplot_kw={"projection": proj},
    constrained_layout=True,
)

# Common vmin/vmax for original & prediction (thermal map)
vmin = np.nanmin([y_true, y_pred])
vmax = np.nanmax([y_true, y_pred])

# Symmetric range for the difference (diverging map)
diff_absmax = np.nanmax(np.abs(y_diff))

# Data colormap: colorblind-friendly thermal (Matplotlib's 'inferno')
data_cmap = "plasma"
# Difference colormap: colorblind-friendly diverging
diff_cmap = "coolwarm"

# Helper to set up each map axis
def setup_map_axis(ax, title):
    ax.set_title(title)
    ax.coastlines(color="black", linewidth=0.5)
    ax.add_feature(cfeature.BORDERS, edgecolor="black", linewidth=0.3)
    ax.set_global()
    gl = ax.gridlines(draw_labels=True, linestyle="--", linewidth=0.3)
    gl.top_labels = False
    gl.right_labels = False

# Panel 1: original field
ax = axes[0]
setup_map_axis(ax, "Original field")
im0 = ax.pcolormesh(
    lon2d,
    lat2d,
    y_true,
    transform=proj,
    cmap=data_cmap,
    vmin=vmin,
    vmax=vmax,
)
cbar0 = fig.colorbar(im0, ax=ax, orientation="vertical", pad=0.02)
cbar0.set_label("Value")

# Panel 2: predicted field
ax = axes[1]
setup_map_axis(ax, "Predicted field")
im1 = ax.pcolormesh(
    lon2d,
    lat2d,
    y_pred,
    transform=proj,
    cmap=data_cmap,
    vmin=vmin,
    vmax=vmax,
)
cbar1 = fig.colorbar(im1, ax=ax, orientation="vertical", pad=0.02)
cbar1.set_label("Value")

# Panel 3: difference
ax = axes[2]
setup_map_axis(ax, "Difference (pred - orig)")
im2 = ax.pcolormesh(
    lon2d,
    lat2d,
    y_diff,
    transform=proj,
    cmap=diff_cmap,
    vmin=-diff_absmax,
    vmax=diff_absmax,
)
cbar2 = fig.colorbar(im2, ax=ax, orientation="vertical", pad=0.02)
cbar2.set_label("Value")

plt.show()

# -------------------------------------------------------------------
# 6. Quick diagnostic
# -------------------------------------------------------------------
field_mean = np.mean(Y_pred_full)
print(f"Mean predicted value over all samples: {field_mean:.3f}")
