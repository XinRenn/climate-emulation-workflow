"""
Extract emulator predictions at UK grid points and save per-variable per-scenario
txt files (shape: 90 members × 1001 timesteps).

Ice-state selection per member per timestep:
  GSL (column 'ice' in forcing file) < 0  →  use modhighice prediction
  GSL >= 0                               →  use modlowice prediction

Input:  /Volumes/Xin-data/NWS_outputs/{var}_{state}/{var}_{state}_{scen}_{member}_prediction.nc
GSL:    ../2_GSL_model/results/emul_inputs_updatedCO2/emul_inputs_{scen}.{member}.updated.res
Output: site_data/site_{site}/{var}_{scen}_site_{site}.txt

NWS naming convention (data_name_guidance.md):
  - Open format: .txt (whitespace-separated, readable by np.loadtxt)
  - Flat structure: one subfolder per site (site_LA/, site_LB/, ...)
  - Meaningful names: {variable}_{scenario}_site_{site}.txt
"""

from pathlib import Path
import numpy as np
import pandas as pd
import xarray as xr

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

NWS_OUTPUTS = Path("/Volumes/Xin-data/NWS_outputs")
GSL_PATH    = Path("../2_GSL_model/results/emul_inputs_updatedCO2")
SITE_DATA   = Path("/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/NWS-PDRA/NWS_emulation/prediction/results_on_sites")   # output root (relative to this script)

VARS = [
    "tas", "precip", "evap", "windspeed", "ice_sheet",
    "iceconc", "LAI_PFT", "snowdepth", "sm", "soiltemp",
]
SCENARIOS = ["natural", "SSP126", "SSP245", "SSP370", "SSP585", "10000PGC"]
N_MEMBERS = 90

# UK grid indices into HadCM3 global grid (from Make_site_txt.py)
LAND_SITES = {"LA": (14, -1), "LB": (15, -1), "LC": (15,  0),"LD": (16, 0)}
SEA_SITES  = {"SA": (16, -1), "SB": (15,  1)}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def load_prediction(var, state, scen, member):
    """Return (time, lat, lon) numpy array from prediction NetCDF."""
    fname = f"{var}_{state}_{scen}_{member}_prediction.nc"
    fpath = NWS_OUTPUTS / f"{var}_{state}" / fname
    with xr.open_dataset(str(fpath)) as ds:
        return ds["var"].values  # (n_time, n_lat, n_lon)


def load_gsl(scen, member):
    """Return GSL time series (1001,) from forcing file, column 'ice'."""
    fname = f"emul_inputs_{scen}.{member}.updated.res"
    df = pd.read_csv(GSL_PATH / fname, header=0, sep=r'\s+')
    return df["ice"].values  # (1001,)


# ---------------------------------------------------------------------------
# Main extraction loop
# ---------------------------------------------------------------------------

SITE_DATA.mkdir(parents=True, exist_ok=True)
for site in {**LAND_SITES, **SEA_SITES}:
    (SITE_DATA / f"site_{site}").mkdir(exist_ok=True)

for var in VARS:
    sites = SEA_SITES if var == "iceconc" else {**LAND_SITES, **SEA_SITES}

    for scen in SCENARIOS:
        print(f"\n[{var}] {scen}", flush=True)

        # Accumulate (member, time) arrays per site
        site_arrays = {s: np.empty((N_MEMBERS, 1001), dtype=np.float32)
                       for s in sites}

        for m in range(1, N_MEMBERS + 1):
            gsl      = load_gsl(scen, m)                              # (1001,)
            glacial  = gsl < 0.0                                      # bool (1001,)
            high_arr = load_prediction(var, "modhighice", scen, m)   # (1001, lat, lon)
            low_arr  = load_prediction(var, "modlowice",  scen, m)   # (1001, lat, lon)

            for site_name, (lat_i, lon_i) in sites.items():
                high_t = high_arr[:, lat_i, lon_i]   # (1001,)
                low_t  = low_arr[:,  lat_i, lon_i]   # (1001,)
                site_arrays[site_name][m - 1, :] = np.where(glacial, high_t, low_t)

            if m % 10 == 0:
                print(f"  member {m:3d}/90", flush=True)

        # Save per site
        for site_name, arr in site_arrays.items():
            out_file = SITE_DATA / f"site_{site_name}" / f"{var}_{scen}_site_{site_name}.txt"
            np.savetxt(str(out_file), arr, fmt="%.6e")
            print(f"  -> {out_file}  shape={arr.shape}", flush=True)

print("\nDone.")
