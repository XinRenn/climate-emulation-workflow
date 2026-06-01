"""
Train a PCA+GP emulator, predict under scenario forcing, and plot on
"""


from paleo_emu.runner import PaleoEmuRunner
from paleo_emu.plotter import PaleoEmuPlotter
# --- train and predict ---

vars=["tas","precip","evap","windspeed","ice_sheet","iceconc","LAI_PFT","snowdepth","sm","soiltemp"]
states=["modhighice","modlowice"]
for var in vars:
    for state in states:
        runner = PaleoEmuRunner("prediction.yml")
        runner.cfg.model_run_name = f"{var}_{state}"
        runner.cfg.X_input_file_name = f"emul_in_X_{state}.res"
        runner.cfg.Y_input_file_name = f"emul_in_Y_{state}_{var}.nc"
        runner.train()
        runner.predict("natural")
        print("--------------Done 1/6---------------")
        print(f"Predicted: {var}_{state} under natural scenario")
        runner.predict("SSP126")
        print("--------------Done 2/6---------------")
        print(f"Predicted: {var}_{state} under SSP126 scenario")
        runner.predict("SSP245")
        print("--------------Done 3/6---------------")
        print(f"Predicted: {var}_{state} under SSP245 scenario")
        runner.predict("SSP370")
        print("--------------Done 4/6---------------")
        print(f"Predicted: {var}_{state} under SSP370 scenario")
        runner.predict("SSP585")
        print("--------------Done 5/6---------------")
        print(f"Predicted: {var}_{state} under SSP585 scenario")
        runner.predict("10000PGC")
        print("--------------Done 6/6---------------")
        print(f"Predicted: {var}_{state} under 10000PGC scenario")


# # --- plot ---
# plotter = PaleoEmuPlotter("prediction.yml")
# plotter.timeseries("SSP585", cfg="prediction.yml")
