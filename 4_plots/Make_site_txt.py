import xarray as xr
import numpy as np
import pandas as pd
import os
import gc



def main(variable, scenario, site="UK", bias_correction = False, plot=True):
    if site == 'UK':
        # site_lon_index = -2  # -1,15
        # site_lat_index = 15
        # site_lon_indexs = [-1,-2,-1,-1,0]
        # site_lat_indexs = [14,15,15,13,15]
        # site_lon_index_UK_sea = [-1,-2,-3,-2,-2,-1, 0, 0, 1]
        # site_lat_index_UK_sea = [16,16,15,14,13,12,13,14,15]
        # site_lon_index_cru = [353, 353, 350, 352, 363, 363, 362, 361, 354, 352, 354, 356]  # Adjusted to include 613-620
        # site_lat_index_cru = [71 ,  70,  67,  73,  74,  75,  76,  78,  77,  77,  78,  76] # Adjusted to include 104-111
        # sitenameL = ["LA","LB","LC","LD","LE"]
        # sitenameS = ["SA","SB","SC","SD","SE","SF","SG","SH","SI"]
        site_lon_index = -2  # -1,15
        site_lat_index = 15
        site_lon_indexs = [-1,-1,0]
        site_lat_indexs = [14,15,15]
        site_lon_index_UK_sea = [-1,1]
        site_lat_index_UK_sea = [16,15]
        site_lon_index_cru = [353, 350, 363]  # Adjusted to include 613-620
        site_lat_index_cru = [71, 67, 74]  # Adjusted to include 104-111
        sitenameL = ["LA","LB","LC"]
        sitenameS = ["SA","SB"]
    elif site == 'KAERI':
        site_lon_index = 34
        site_lat_index = 21
        site_lon_index_sea = [33, 35, 34]
        site_lat_index_sea = [21, 21, 20]
        site_lon_index_cru = 615  # Adjusted to include 613-620
        site_lat_index_cru = 107  # Adjusted to include 104-111
    elif site == 'SKB':
        site_lon_index = 5 #4 is the nearest point, 5 is the actual site
        site_lat_index = 12
        site_lon_index_cru = [396]
        site_lat_index_cru = [59 ]

    member = 90  # Number of ensemble members

    mean_values_low = []
    for i in range(1,member+1):
        file_path = f'/Volumes/Xin-data/result/{variable}/{variable}_modlowice_{scenario}_{i}_predictions.nc'
        # file_path = f'/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/NWS_emulation/prediction/results/{variable}/{variable}_modlowice_{scenario}_{i}_predictions.nc'
        data = xr.open_dataset(file_path)
        mean_variable = data['var']
        latitude = data['lat'].values
        longitude = data['lon'].values
        if(variable == "tas" or variable == "precip"):
            mean_variable = mean_variable[::-1,:,:] # Flip time to debug. Remember to remove this line after debugging.
        mean_values_low.append(mean_variable.astype("float64").values)

    ensemble_array_low = np.array(mean_values_low, dtype=np.float64)
    print("Ensemble array shape:", ensemble_array_low.shape)

    mean_values_high = []
    for i in range(1,member+1):
        file_path = f'/Volumes/Xin-data/result/{variable}/{variable}_modhighice_{scenario}_{i}_predictions.nc'
        # file_path = f'/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/NWS_emulation/prediction/results/{variable}/{variable}_modhighice_{scenario}_{i}_predictions.nc'
        data = xr.open_dataset(file_path)
        mean_variable = data['var']
        if(variable == "tas" or variable == "precip"):
            mean_variable = mean_variable[::-1,:,:] # Flip time to debug. Remember to remove this line after debugging.
        mean_values_high.append(mean_variable.astype("float64").values)

    ensemble_array_high = np.array(mean_values_high, dtype=np.float64)
    print("Ensemble array shape:", ensemble_array_high.shape)

    ice_all = []
    for i in range(1,member+1):
        path = "/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/Results/"
        prediction_input = path + f"emul_inputs_{scenario}.{i}.updated.res"
        emu_input_data = pd.read_csv(prediction_input, sep=r'\s+', header=0)
        ice = emu_input_data.iloc[:, 4].values
        ice_all.append(ice)

    ice_all = np.array(ice_all)

    ensemble_array_all = np.empty_like(ensemble_array_high, dtype=np.float64)

    for x in range(ensemble_array_all.shape[0]):
        for y in range(ensemble_array_all.shape[1]):
            if ice_all[x][y] < 0.0:
                ensemble_array_all[x,y,:,:] = ensemble_array_high[x, y, :, :]
            else:
                ensemble_array_all[x,y,:,:] = ensemble_array_low[x, y, :, :]

    del ensemble_array_low, ensemble_array_high

    ensemble_array = np.array(ensemble_array_all)

    if variable == "snowdepth":
        ensemble_array[ensemble_array < 0.0] = 0.0

    # if variable == "ice_sheet":
    #     ensemble_array[ensemble_array <= 0.5] = 0.0
    #     ensemble_array[ensemble_array > 0.5] = 1.0  # it should be 0 or 1

    if bias_correction == True and variable in ["temp", "precip"]:
        CRU_oro_file = "/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Charlie/Emulator/2015_Bristol_5D_v001/orig/Input/2018-08-01 Final report/cru-elevation.nc"
        cru_oro_data = xr.open_dataset(CRU_oro_file)
        cru_oro = cru_oro_data['elv']

        if variable == "precip":
            cru_file = "/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Charlie/Emulator/2015_Bristol_5D_v001/orig/Input/2018-08-01 Final report/clim.6190.lan.pre.nc"
            cru_data = xr.open_dataset(cru_file)
            cru_variable = cru_data['pre']
            cru_lat = cru_data['lat'].values
            cru_lon = cru_data['lon'].values
        else:
            cru_file = "/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Charlie/Emulator/2015_Bristol_5D_v001/orig/Input/2018-08-01 Final report/clim.6190.lan.tmp.nc"
            cru_data = xr.open_dataset(cru_file)
            cru_variable = cru_data['tmp']
            cru_lat = cru_data['lat'].values
            cru_lon = cru_data['lon'].values

        if variable == "precip":
            pi_file = "/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Charlie/Emulator/2015_Bristol_5D_v001/orig/Input/2018-08-01 Final report/tdstb_cl_precip_mm_srf_interp_smooth.nc"
            pi_data = xr.open_dataset(pi_file)
            pi_variable = pi_data['precip_mm_srf']
            pi_lat = pi_data['lat'].values
            pi_lon = pi_data['lon'].values
        else:
            pi_file = "/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Charlie/Emulator/2015_Bristol_5D_v001/orig/Input/2018-08-01 Final report/tdstb_cl_temp_mm_1_5m_interp_smooth.nc"
            pi_data = xr.open_dataset(pi_file)
            pi_variable = pi_data['temp_mm_1_5m']- 273.15
            pi_lat = pi_data['lat'].values
            pi_lon = pi_data['lon'].values

        cru_mean = cru_variable.mean(dim='time').values

        from scipy.interpolate import RegularGridInterpolator
        pi_interp = RegularGridInterpolator(
            (pi_lat, pi_lon),
            pi_variable[0,0,:,:].values,
            method="linear",
            bounds_error=False,
            fill_value=np.nan
        )
        lon_grid, lat_grid = np.meshgrid(cru_lon, cru_lat)
        points_interp = np.stack([lat_grid.ravel(), lon_grid.ravel()], axis=-1)
        pi_var_cru_regrid_orig = pi_interp(points_interp).reshape(cru_mean.shape)

        if cru_lat[0] < cru_lat[-1]:
            cru_lat = cru_lat[::-1]
            cru_mean = cru_mean[::-1, :]
            cru_oro = cru_oro[::-1, :]
            pi_var_cru_regrid = pi_var_cru_regrid_orig[::-1, :]
            print("Flipping interpolated PI variable back to match CRU's orientation.")
        else:
            pi_var_cru_regrid = pi_var_cru_regrid_orig

        pi_var_cru_regrid[np.isnan(cru_oro)] = np.nan

        CRU_bias_kaeri = np.zeros((len(site_lat_index_cru)), dtype=np.float64)
        if variable == "precip":
            for x in range(len(site_lat_index_cru)):
                CRU_bias_kaeri[x] = pi_var_cru_regrid[site_lat_index_cru[x], site_lon_index_cru[x]]*60.0*60.0*24.0*30.0 / cru_mean[site_lat_index_cru[x], site_lon_index_cru[x]]
        elif variable == "temp":
            for x in range(len(site_lat_index_cru)):
                CRU_bias_kaeri[x] =  pi_var_cru_regrid[site_lat_index_cru[x], site_lon_index_cru[x]] - cru_mean[site_lat_index_cru[x], site_lon_index_cru[x]] - pi_var_cru_regrid[site_lat_index_cru[x], site_lon_index_cru[x]]


        cru_lon_wrapped = np.where(cru_lon > 180, cru_lon - 360, cru_lon)
        # Get the sorted indices
        sorted_idx_cru = np.argsort(cru_lon_wrapped)

        from scipy.interpolate import RegularGridInterpolator
        x_idx = np.linspace(1, 96, 96)
        y_idx =  np.linspace(1, 73, 73)
        x_target = np.linspace(1, 96, 720)
        y_target = np.linspace(1, 73, 360)
        grid_x, grid_y = np.meshgrid(x_target, y_target)
        interp_points = np.stack([grid_y.ravel(), grid_x.ravel()], axis=-1)
        ensemble_array_cru = np.zeros(( 360, 720))
        var_kaeri = np.zeros((len(site_lat_index_cru), ensemble_array.shape[0], ensemble_array.shape[1]))
        print("Start to interpolate ensemble array to CRU grid!")
        for m in range(ensemble_array.shape[0]):
            for t in range(ensemble_array.shape[1]):
                ensemble_array_cru = np.zeros(( 360, 720))
                interp_fn = RegularGridInterpolator(
                    (y_idx, x_idx),
                    ensemble_array[m, t, :, :],
                    method='linear',
                    bounds_error=False,
                    fill_value=np.nan
                )
                ensemble_array_cru[:,:] = interp_fn(interp_points).reshape(360, 720)
                ensemble_array_cru = ensemble_array_cru[:, sorted_idx_cru]
                for x in range(len(site_lat_index_cru)):
                    var_kaeri[x,m,t] = ensemble_array_cru[site_lat_index_cru[x], site_lon_index_cru[x]]
                del interp_fn, ensemble_array_cru 

        print(var_kaeri[0,0,0:10])

    if variable == "iceconc":
        site_lat_indexs = site_lat_index_UK_sea
        site_lon_indexs = site_lon_index_UK_sea
    
    if bias_correction and variable in ["temp", "precip"]:
        site_lat_indexs = site_lat_index_cru[:]
        site_lon_indexs = site_lon_index_cru[:]

    # start site loop for plotting
    if isinstance(site_lat_indexs, int) or ((isinstance(site_lat_indexs, list) and len(site_lat_indexs) == 1)):
        site_indices = [0]
    else:
        site_indices = range(len(site_lat_indexs))
    
    for site_index in site_indices:

        if isinstance(site_lat_indexs, int) or ((isinstance(site_lat_indexs, list) and len(site_lat_indexs) == 1)):
            site_lat_index = site_lat_indexs
            site_lon_index = site_lon_indexs
        else:
            site_lat_index = site_lat_indexs[site_index]
            site_lon_index = site_lon_indexs[site_index]

        # Extract the oceanic points for UK sea if site index didn't change previously
        # if site == "UK":
        #     if variable == "iceconc":
        #         # For ice concentration, we need to average over the UK points
        #         var_kaeri_site = np.zeros((ensemble_array.shape[0], ensemble_array.shape[1], len(site_lat_index)))
        #         for idx in range(len(site_lat_index)):
        #             var_kaeri_site[:, idx] = ensemble_array[:,:, site_lat_index[idx], site_lon_index[idx]] # Dynamically handle UK points
        #         print("latitude for UK sea points:", latitude[site_lat_index])
        #         for idx in range(len(site_lat_index_UK_sea)):
        #             var_kaeri_site[:, idx] = ensemble_array[:,:, site_lat_index_UK_sea[idx], site_lon_index_UK_sea[idx]]
        #         var_kaeri = np.mean(var_kaeri_site, axis=2)  # Use mean instead of sum for better representation

        if not bias_correction:
            var_kaeri = ensemble_array[:, :, site_lat_index, site_lon_index]

        var_kaeri_ano = np.zeros_like(ensemble_array[:, :,0,0], dtype=np.float64)

        if bias_correction:
            if variable == "precip":
                if var_kaeri_ano.ndim == 2:
                    for i in range(var_kaeri.shape[1]):
                        var_kaeri_ano[:, i] = (var_kaeri[site_index,:, i] + pi_var_cru_regrid[site_lat_index_cru[site_index], site_lon_index_cru[site_index]]*60.0*60.0*24.0*30.0 ) / np.nanmean(CRU_bias_kaeri[site_index]) 
                else:
                    var_kaeri_ano = (var_kaeri + pi_var_cru_regrid[site_lat_index_cru[site_index], site_lon_index_cru[site_index]]*60.0*60.0*24.0*30.0) / np.nanmean(CRU_bias_kaeri[site_index])
            elif variable == "temp":
                if var_kaeri_ano.ndim == 2:
                    for i in range(var_kaeri.shape[1]):
                        var_kaeri_ano[:, i] = var_kaeri[site_index,:, i] - np.nanmean(CRU_bias_kaeri[site_index])
                else:
                    var_kaeri_ano = var_kaeri[site_index] - np.nanmean(CRU_bias_kaeri[site_index])
            print("CRU_bias_kaeri:",np.nanmean(CRU_bias_kaeri[site_index]))
        else:
            var_kaeri_ano[:,:] = var_kaeri.copy()
        
        print("shape of var_kaeri_ano:", var_kaeri_ano.shape)
        # Save var_kaeri_ano as .res file
        # Save var_kaeri_ano as .txt file with heading and explanation
        if bias_correction:
            fig_file_path = f"/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/NWS_emulation/prediction/results/downscaled"
            output_file = f"{fig_file_path}/{variable}_{scenario}_site{site_index}_downscaled.txt"
        else:
            if variable == "iceconc":
                fig_file_path = f"/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/NWS_emulation/prediction/results/sites/site_{sitenameS[site_index]}"
                output_file = f"{fig_file_path}/{variable}_{scenario}_site_{sitenameS[site_index]}.txt"
            else:
                fig_file_path = f"/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/NWS_emulation/prediction/results/sites/site_{sitenameL[site_index]}"
                output_file = f"{fig_file_path}/{variable}_{scenario}_site_{sitenameL[site_index]}.txt"
        os.makedirs(fig_file_path, exist_ok=True)
        
        # Prepare header with explanation
        if bias_correction:
            header_lines = [
                f"# Variable: {variable}",
                f"# Scenario: {scenario}",
                f"# Downscaled site index: {site_index}",
                f"# Units: {units[var_index]}",
                f"# Long name: {longnames[var_index]}",
                "# Each row is an ensemble member, each column is a time step (AP kyr).",
                "# Values are absolute value.",
                "# Bias correction applied using CRU data.",
                "#"
            ]
        else:
            header_lines = [
                f"# Variable: {variable}",
                f"# Scenario: {scenario}",
                f"# Site index: {site_index}",
                f"# Units: {units[var_index]}",
                f"# Long name: {longnames[var_index]}",
                "# Each row is an ensemble member, each column is a time step (AP kyr).",
                "# Values are anomalies unless otherwise stated.",
                "#"
            ]

        header = "\n".join(header_lines)
        
        np.savetxt(output_file, var_kaeri_ano, fmt="%.6f", header=header)
        print(f"Saved {output_file} with header and explanation")
        
    del ensemble_array, ensemble_array_all, var_kaeri_ano, var_kaeri
    gc.collect()
    print(f"Done processing {variable} in scenario {scenario}.")
    


variables = ["tas","precip","evap","soiltemp","sm","snowdepth","LAI_PFT","windspeed","iceconc","ice_sheet"]  # This is the variable to be emulated
units = ["degC", "mm month^-1", "mm month^-1", "degC", "kg m^-2", "kg m^-2", "leaf area index LAI", "m s^-1", "%"," "]  # Units for each variable
longnames = [
    "2m Air Temperature",
    "Surface Precipitation",
    "Evapotranspiration",
    "Soil Temperature from top layer",
    "Soil Moisture from top layer",
    "Snow Depth",
    "Leaf Area Index (LAI)",
    "10m Wind Speed",
    "Sea Ice Concentration",
    "Ice Sheet 0/1"
]  # Long names for each variable
# scenarios=["natural","SSP126","SSP245","SSP370","SSP460","SSP534","SSP585","10000PGC"]
scenarios=["10000PGC"]
# scenarios = ["SSP534","SSP585"]

var_index = 8  # Index for the variable to process 9 in total
scen_index = 0  # Index for the scenario to process
if __name__ == "__main__":
    variable = variables[var_index]
    for scen_index, scenario in enumerate(scenarios):
        bias_correction = False
        plot = False
        main(variable, scenario, site="UK", bias_correction = bias_correction , plot = plot)
        total_steps = 1 * len(scenarios)
        current_step = scen_index + 1
        progress_percent = (current_step / total_steps) * 100
        print(f"Overall progress: {progress_percent:.2f}% ({current_step}/{total_steps})")
        cleanup_var = variable + "_" + scenario
        del cleanup_var

# if __name__ == "__main__":
#     for var_index, variable in enumerate(variables[0:0], start=0):
#         for scen_index, scenario in enumerate(scenarios):
#             bias_correction = True
#             plot = False
#             main(variable, scenario, site="UK", bias_correction = bias_correction , plot = plot)
#             total_steps = len(variables) * len(scenarios)
#             current_step = var_index * len(scenarios) + scen_index + 1
#             progress_percent = (current_step / total_steps) * 100
#             print(f"Overall progress: {progress_percent:.2f}% ({current_step}/{total_steps})")
