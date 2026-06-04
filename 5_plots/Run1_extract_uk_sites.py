"""
Extract emulator predictions at UK grid points and save per-variable per-scenario
txt files (shape: 90 members × 1001 timesteps).

Ice-state selection per member per timestep:
  GSL (column 'ice' in forcing file) < 0  →  use modhighice prediction
  GSL >= 0                               →  use modlowice prediction

Input:  /Volumes/Xin-data/NWS_outputs/{var}_{state}_{scen}_{member}_prediction.nc
GSL:    2_GSL_model/results/emul_inputs_updatedCO2/emul_inputs_{scen}.{member}.updated.res
Output: site_data/site_{site}/{var}_{scen}_site_{site}.txt

NWS naming convention (data_name_guidance.md):
  - Open format: .txt (whitespace-separated, readable by np.loadtxt)
  - Flat structure: one subfolder per site (site_LA/, site_LB/, ...)
  - Meaningful names: {variable}_{scenario}_site_{site}.txt
  - Header lines with metadata (variable, scenario, site, units, description)
"""

from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import numpy as np
import pandas as pd
import xarray as xr

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

_HERE       = Path(__file__).parent
NWS_OUTPUTS = Path("/Volumes/Xin-data/NWS_outputs")
GSL_PATH    = _HERE.parent / "2_GSL_model/results/emul_inputs_updatedCO2"
SITE_DATA   = _HERE / "site_data"  # notebooks in 5_plots/ read from "site_data/"

N_WORKERS = 8  # parallel member reads; tune to drive bandwidth

VARS = [
    "evap", "windspeed", "LAI_PFT", "sm", "snowdepth", "tas",
    # add when modlowice files are complete:
    # "ice_sheet",  — modlowice missing entirely
    # "precip",     — modlowice missing entirely
    # "iceconc",    — both states incomplete
    # "soiltemp",   — both states incomplete
]
SCENARIOS = ["natural", "SSP126", "SSP245", "SSP370", "SSP585", "10000PGC"]
N_MEMBERS = 90

# UK grid indices into HadCM3 global grid (from Make_site_txt.py)
LAND_SITES = {"LA": (14, -1), "LB": (15, -1), "LC": (15,  0), "LD": (16, 0)}
SEA_SITES  = {"SA": (16, -1), "SB": (15,  1)}

# Variable metadata for NWS file headers (units from Make_site_txt.py)
UNITS = {
    "tas":       "degC",
    "precip":    "mm month^-1",
    "evap":      "mm month^-1",
    "windspeed": "m s^-1",
    "ice_sheet": " ",
    "iceconc":   "%",
    "LAI_PFT":   "leaf area index LAI",
    "snowdepth": "kg m^-2",
    "sm":        "kg m^-2",
    "soiltemp":  "degC",
}
LONG_NAMES = {
    "tas":       "2m Air Temperature",
    "precip":    "Surface Precipitation",
    "evap":      "Evapotranspiration",
    "windspeed": "10m Wind Speed",
    "ice_sheet": "Ice Sheet 0/1",
    "iceconc":   "Sea Ice Concentration",
    "LAI_PFT":   "Leaf Area Index (LAI)",
    "snowdepth": "Snow Depth",
    "sm":        "Soil Moisture from top layer",
    "soiltemp":  "Soil Temperature from top layer",
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def load_prediction(var, state, scen, member):
    """Return (time, lat, lon) numpy array from prediction NetCDF."""
    fname = f"{var}_{state}_{scen}_{member}_prediction.nc"
    with xr.open_dataset(str(NWS_OUTPUTS / fname), engine="netcdf4") as ds:
        return ds["var"].values  # (n_time, n_lat, n_lon)


def load_gsl(scen, member):
    """Return GSL time series (1001,) from forcing file, column 'ice'."""
    fname = f"emul_inputs_{scen}.{member}.updated.res"
    df = pd.read_csv(GSL_PATH / fname, header=0, sep=r'\s+')
    return df["ice"].values  # (1001,)


def extract_member(var, scen, m, sites):
    """Load both ice states for one member, return per-site extracted arrays."""
    gsl     = load_gsl(scen, m)
    glacial = gsl < 0.0                                        # (1001,) bool
    high    = load_prediction(var, "modhighice", scen, m)     # (1001, lat, lon)
    low     = load_prediction(var, "modlowice",  scen, m)     # (1001, lat, lon)
    return m, {
        site: np.where(glacial, high[:, lat_i, lon_i], low[:, lat_i, lon_i])
        for site, (lat_i, lon_i) in sites.items()
    }


def all_sites_done(var, scen, sites):
    """Return True if all output files for this (var, scen) already exist."""
    return all(
        (SITE_DATA / f"site_{s}" / f"{var}_{scen}_site_{s}.txt").exists()
        for s in sites
    )


# ---------------------------------------------------------------------------
# Main extraction loop
# ---------------------------------------------------------------------------

SITE_DATA.mkdir(parents=True, exist_ok=True)
for site in {**LAND_SITES, **SEA_SITES}:
    (SITE_DATA / f"site_{site}").mkdir(exist_ok=True)

for var in VARS:
    sites = SEA_SITES if var == "iceconc" else {**LAND_SITES, **SEA_SITES}

    for scen in SCENARIOS:
        if all_sites_done(var, scen, sites):
            print(f"[{var}] {scen} — already done, skipping", flush=True)
            continue

        print(f"\n[{var}] {scen} — processing {N_MEMBERS} members "
              f"({N_WORKERS} parallel)", flush=True)

        site_arrays = {s: np.empty((N_MEMBERS, 1001), dtype=np.float32)
                       for s in sites}
        done = 0

        with ThreadPoolExecutor(max_workers=N_WORKERS) as pool:
            futures = {
                pool.submit(extract_member, var, scen, m, sites): m
                for m in range(1, N_MEMBERS + 1)
            }
            for fut in as_completed(futures):
                m, result = fut.result()
                for site_name, vals in result.items():
                    site_arrays[site_name][m - 1, :] = vals
                done += 1
                if done % 10 == 0:
                    print(f"  {done:3d}/90 members done", flush=True)

        # Clip physically bounded variables
        if var == "snowdepth":
            for arr in site_arrays.values():
                np.clip(arr, 0.0, None, out=arr)

        # Save per site
        for site_name, arr in site_arrays.items():
            out_file = SITE_DATA / f"site_{site_name}" / f"{var}_{scen}_site_{site_name}.txt"
            header = (
                f"Variable: {var}\n"
                f"Long name: {LONG_NAMES[var]}\n"
                f"Units: {UNITS[var]}\n"
                f"Scenario: {scen}\n"
                f"Site: {site_name}\n"
                f"Shape: 90 ensemble members x 1001 time steps\n"
                f"Rows: ensemble members (1-90); Columns: time steps (0 to 1000 kyr AP)\n"
                f"Ice-state selection: GSL<0 -> modhighice, GSL>=0 -> modlowice"
            )
            np.savetxt(str(out_file), arr, fmt="%.6f", header=header)
            print(f"  -> {out_file.name}  shape={arr.shape}", flush=True)

print("\nDone.")
