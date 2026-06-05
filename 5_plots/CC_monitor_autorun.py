"""
CC_monitor_autorun.py
---------------------
Monitors /Volumes/Xin-data/NWS_outputs/ for newly completed prediction files.
When a (var, scen) combo reaches 90/90 members for BOTH ice states:
  1. Runs make_site extraction (Run1_extract_uk_sites logic)
  2. Re-executes Plot_Figure3.4_prediction_on_site.ipynb

Usage:
    /opt/homebrew/anaconda3/envs/emu/bin/python CC_monitor_autorun.py

Stop with Ctrl-C.
"""

import time, sys, subprocess, re, importlib.util, logging
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

import numpy as np
import pandas as pd
import xarray as xr

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
HERE        = Path(__file__).parent
NWS_OUTPUTS = Path("/Volumes/Xin-data/NWS_outputs")
GSL_PATH    = HERE.parent / "2_GSL_model/results/emul_inputs_updatedCO2"
SITE_DATA   = HERE / "site_data" / "lowres_results"
NOTEBOOK    = HERE / "Plot_Figure3.4_prediction_on_site.ipynb"

POLL_INTERVAL = 60   # seconds between checks

ALL_VARS   = ["evap","windspeed","LAI_PFT","sm","snowdepth","tas",
              "precip","iceconc","soiltemp","ice_sheet"]
SCENARIOS  = ["natural","SSP126","SSP245","SSP370","SSP585","10000PGC"]
N_MEMBERS  = 90
N_WORKERS  = 8

LAND_SITES = {"LA": (14, -1), "LB": (15, -1), "LC": (15,  0), "LD": (16, 0)}
SEA_SITES  = {"SA": (16, -1), "SB": (15,  1)}

UNITS = {
    "tas": "degC", "precip": "mm month^-1", "evap": "mm month^-1",
    "windspeed": "m s^-1", "ice_sheet": " ", "iceconc": "%",
    "LAI_PFT": "leaf area index LAI", "snowdepth": "kg m^-2",
    "sm": "kg m^-2", "soiltemp": "degC",
}
LONG_NAMES = {
    "tas": "2m Air Temperature", "precip": "Surface Precipitation",
    "evap": "Evapotranspiration", "windspeed": "10m Wind Speed",
    "ice_sheet": "Ice Sheet 0/1", "iceconc": "Sea Ice Concentration",
    "LAI_PFT": "Leaf Area Index (LAI)", "snowdepth": "Snow Depth",
    "sm": "Soil Moisture from top layer", "soiltemp": "Soil Temperature from top layer",
}

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s %(message)s",
                    datefmt="%H:%M:%S")
log = logging.getLogger()

# ---------------------------------------------------------------------------
# Helpers (mirrored from Run1_extract_uk_sites.py)
# ---------------------------------------------------------------------------

def count_downloaded():
    """Return dict (var, state, scen) → set of member ints present in NWS_outputs."""
    counts = {}
    for f in NWS_OUTPUTS.glob("*_prediction.nc"):
        m = re.match(r'(.+)_(modhighice|modlowice)_(.+)_(\d+)_prediction\.nc', f.name)
        if m:
            var, state, scen, mem = m.groups()
            counts.setdefault((var, state, scen), set()).add(int(mem))
    return counts


def complete_combos(counts):
    """Return set of (var, scen) where BOTH ice states have all 90 members."""
    ready = set()
    for var in ALL_VARS:
        for scen in SCENARIOS:
            hi = counts.get((var, "modhighice", scen), set())
            lo = counts.get((var, "modlowice",  scen), set())
            if len(hi) == N_MEMBERS and len(lo) == N_MEMBERS:
                ready.add((var, scen))
    return ready


def sites_for_var(var):
    return SEA_SITES if var == "iceconc" else {**LAND_SITES, **SEA_SITES}


def all_sites_done(var, scen):
    sites = sites_for_var(var)
    return all(
        (SITE_DATA / f"{var}_{scen}_site_{s}.txt").exists()
        for s in sites
    )


def load_prediction(var, state, scen, member):
    fname = NWS_OUTPUTS / f"{var}_{state}_{scen}_{member}_prediction.nc"
    with xr.open_dataset(str(fname), engine="netcdf4") as ds:
        return ds["var"].values   # (n_time, n_lat, n_lon)


def load_gsl(scen, member):
    fname = GSL_PATH / f"emul_inputs_{scen}.{member}.updated.res"
    df = pd.read_csv(fname, header=0, sep=r'\s+')
    return df["ice"].values


def extract_member(var, scen, m, sites):
    gsl     = load_gsl(scen, m)
    glacial = gsl < 0.0
    high    = load_prediction(var, "modhighice", scen, m)
    low     = load_prediction(var, "modlowice",  scen, m)
    return m, {
        site: np.where(glacial, high[:, lat_i, lon_i], low[:, lat_i, lon_i])
        for site, (lat_i, lon_i) in sites.items()
    }


def run_extraction(var, scen):
    """Extract one (var, scen) combo to site_data/."""
    sites = sites_for_var(var)
    log.info(f"  Extracting {var} / {scen} ({len(sites)} sites, {N_WORKERS} workers)…")

    site_arrays = {s: np.empty((N_MEMBERS, 1001), dtype=np.float32) for s in sites}

    with ThreadPoolExecutor(max_workers=N_WORKERS) as pool:
        futures = {pool.submit(extract_member, var, scen, m, sites): m
                   for m in range(1, N_MEMBERS + 1)}
        done = 0
        for fut in as_completed(futures):
            m, result = fut.result()
            for site_name, vals in result.items():
                site_arrays[site_name][m - 1, :] = vals
            done += 1
            if done % 30 == 0:
                log.info(f"    {done}/{N_MEMBERS} members done")

    for site_name, arr in site_arrays.items():
        out = SITE_DATA / f"{var}_{scen}_site_{site_name}.txt"
        header = (
            f"Variable: {var}\nLong name: {LONG_NAMES[var]}\nUnits: {UNITS[var]}\n"
            f"Scenario: {scen}\nSite: {site_name}\n"
            f"Shape: 90 ensemble members x 1001 time steps\n"
            f"Rows: ensemble members (1-90); Columns: time steps (0 to 1000 kyr AP)\n"
            f"Ice-state selection: GSL<0 -> modhighice, GSL>=0 -> modlowice"
        )
        np.savetxt(str(out), arr, fmt="%.6f", header=header)
    log.info(f"  → {var}/{scen} saved")


def run_notebook():
    log.info("Running Plot_Figure3.4_prediction_on_site.ipynb …")
    cmd = [
        "/opt/homebrew/anaconda3/envs/emu/bin/jupyter",
        "nbconvert", "--to", "notebook", "--execute", "--inplace",
        "--ExecutePreprocessor.timeout=600",
        str(NOTEBOOK),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        log.info("  Notebook executed successfully.")
    else:
        log.warning(f"  Notebook execution failed:\n{result.stderr[-500:]}")

# ---------------------------------------------------------------------------
# Main monitor loop
# ---------------------------------------------------------------------------

def main():
    log.info("Monitor started. Checking every %ds. Stop with Ctrl-C.", POLL_INTERVAL)
    SITE_DATA.mkdir(parents=True, exist_ok=True)  # flat: no site_XX subdirs

    done_combos = set()   # (var, scen) already extracted this session

    # Seed with already-complete site_data so we don't re-extract on startup
    for var in ALL_VARS:
        for scen in SCENARIOS:
            if all_sites_done(var, scen):
                done_combos.add((var, scen))
    log.info(f"Already complete at startup: {len(done_combos)} (var, scen) combos.")

    notebook_needed = False

    while True:
        try:
            counts  = count_downloaded()
            ready   = complete_combos(counts)
            new_ready = ready - done_combos   # newly complete this poll

            if new_ready:
                log.info(f"New complete combos: {sorted(new_ready)}")
                for var, scen in sorted(new_ready):
                    if all_sites_done(var, scen):
                        log.info(f"  {var}/{scen} site_data already exists, skipping.")
                        done_combos.add((var, scen))
                        continue
                    try:
                        run_extraction(var, scen)
                        done_combos.add((var, scen))
                        notebook_needed = True
                    except Exception as e:
                        log.error(f"  Extraction failed for {var}/{scen}: {e}")

                if notebook_needed:
                    run_notebook()
                    notebook_needed = False
            else:
                # Progress summary
                total_missing = sum(
                    90 - len(counts.get((var, state, scen), set()))
                    for var in ALL_VARS
                    for state in ("modhighice", "modlowice")
                    for scen in SCENARIOS
                    if len(counts.get((var, state, scen), set())) < 90
                )
                if total_missing:
                    log.info(f"Waiting… {total_missing} files still downloading.")
                else:
                    log.info("All downloads complete. Monitor will keep running.")

        except KeyboardInterrupt:
            log.info("Stopped.")
            break
        except Exception as e:
            log.error(f"Poll error: {e}")

        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    main()
