%%%% SCALE G_IG MODEL TO ACTUAL ICE VOLUME %%%%
% Scales ice volumes calculated by Archer + Ganopolski 2005 model %
% to realistic ice volumes from Singarayer + Valdes 2010 %
% Calculates and plots the results of sensitivity test of CGSLM %
% Plots Figure 5b from final report %

% Xin Nov 2025: updates date paths

clear

% Load ice volume data

v_AG_500k_BPAP_dat = importdata('Results/ice_volume_AG_-0.5_1myr_AP.res'); % Import ice volume data calculated by A+G 2005 model
t_v_AG_500k_BPAP_dat = importdata('Results/temp_v_AG_-0.5_1myr_AP.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model
Rnum_AG_500k_BPAP_dat = importdata('Results/Rnum_AG_-0.5_1myr_AP.res'); % Import g-ig data calculated by A+G 2005 model
v_SV_21k_BP_dat = importdata('/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Charlie/ForcingData/fort_11_ice_volume.res'); % Import ice volume data calculated by S+V 2010
v_SV_125k_BP_dat = importdata('/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Charlie/ForcingData/fort_10_ice_volume.res'); % Import ice volume data calculated by S+V 2010
% data below is for plotting but wont impact the model results
% gl_sites_rcp45_em_sweden_upper_dat = importdata('/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Charlie/ForcingData/glac_periods_rcp45_sweden_upper.txt'); % Import glacial periods projected by emulator for RCP 4.5
% gl_sites_rcp45_em_finland_upper_dat = importdata('/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/Emulator_Charlie/ForcingData/glac_periods_rcp45_finland_upper.txt'); % Import glacial periods projected by emulator for RCP 4.5

v_AG_500k_BPAP_sens_nat_dat = importdata('Results/ice_volume_AG_-0.5_1myr_AP_LHCsamps_nat.res'); % Import ice volume data calculated by A+G 2005 model
v_AG_500k_BPAP_sens_ssp119_dat = importdata('Results/ice_volume_AG_-0.5_1myr_AP_LHCsamps_SSP1-19.res'); % Import ice volume data calculated by A+G 2005 model
v_AG_500k_BPAP_sens_ssp126_dat = importdata('Results/ice_volume_AG_-0.5_1myr_AP_LHCsamps_SSP1-26.res'); % Import ice volume data calculated by A+G 2005 model
v_AG_500k_BPAP_sens_ssp245_dat = importdata('Results/ice_volume_AG_-0.5_1myr_AP_LHCsamps_SSP2-45.res'); % Import ice volume data calculated by A+G 2005 model
v_AG_500k_BPAP_sens_ssp370_dat = importdata('Results/ice_volume_AG_-0.5_1myr_AP_LHCsamps_SSP3-70.res'); % Import ice volume data calculated by A+G 2005 model
v_AG_500k_BPAP_sens_ssp460_dat = importdata('Results/ice_volume_AG_-0.5_1myr_AP_LHCsamps_SSP4-60.res'); % Import ice volume data calculated by A+G 2005 model
v_AG_500k_BPAP_sens_ssp534_dat = importdata('Results/ice_volume_AG_-0.5_1myr_AP_LHCsamps_SSP5-34.res'); % Import ice volume data calculated by A+G 2005 model
v_AG_500k_BPAP_sens_ssp585_dat = importdata('Results/ice_volume_AG_-0.5_1myr_AP_LHCsamps_SSP5-85.res'); % Import ice volume data calculated by A+G 2005 model
t_v_AG_500k_BPAP_sens_nat_dat = importdata('Results/temp_v_AG_-0.5_1myr_AP_LHCsamps_nat.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model
t_v_AG_500k_BPAP_sens_ssp119_dat = importdata('Results/temp_v_AG_-0.5_1myr_AP_LHCsamps_SSP1-19.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model
t_v_AG_500k_BPAP_sens_ssp126_dat = importdata('Results/temp_v_AG_-0.5_1myr_AP_LHCsamps_SSP1-26.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model
t_v_AG_500k_BPAP_sens_ssp245_dat = importdata('Results/temp_v_AG_-0.5_1myr_AP_LHCsamps_SSP2-45.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model
t_v_AG_500k_BPAP_sens_ssp370_dat = importdata('Results/temp_v_AG_-0.5_1myr_AP_LHCsamps_SSP3-70.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model
t_v_AG_500k_BPAP_sens_ssp460_dat = importdata('Results/temp_v_AG_-0.5_1myr_AP_LHCsamps_SSP4-60.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model
t_v_AG_500k_BPAP_sens_ssp534_dat = importdata('Results/temp_v_AG_-0.5_1myr_AP_LHCsamps_SSP5-34.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model
t_v_AG_500k_BPAP_sens_ssp585_dat = importdata('Results/temp_v_AG_-0.5_1myr_AP_LHCsamps_SSP5-85.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model
Rnum_AG_500k_BPAP_sens_nat_dat = importdata('Results/Rnum_AG_-0.5_1myr_AP_LHCsamps_nat.res'); % Import g-ig data calculated by A+G 2005 model
Rnum_AG_500k_BPAP_sens_ssp119_dat = importdata('Results/Rnum_AG_-0.5_1myr_AP_LHCsamps_SSP1-19.res'); % Import g-ig data calculated by A+G 2005 model
Rnum_AG_500k_BPAP_sens_ssp126_dat = importdata('Results/Rnum_AG_-0.5_1myr_AP_LHCsamps_SSP1-26.res'); % Import g-ig data calculated by A+G 2005 model
Rnum_AG_500k_BPAP_sens_ssp245_dat = importdata('Results/Rnum_AG_-0.5_1myr_AP_LHCsamps_SSP2-45.res'); % Import g-ig data calculated by A+G 2005 model
Rnum_AG_500k_BPAP_sens_ssp370_dat = importdata('Results/Rnum_AG_-0.5_1myr_AP_LHCsamps_SSP3-70.res'); % Import g-ig data calculated by A+G 2005 model
Rnum_AG_500k_BPAP_sens_ssp460_dat = importdata('Results/Rnum_AG_-0.5_1myr_AP_LHCsamps_SSP4-60.res'); % Import g-ig data calculated by A+G 2005 model
Rnum_AG_500k_BPAP_sens_ssp534_dat = importdata('Results/Rnum_AG_-0.5_1myr_AP_LHCsamps_SSP5-34.res'); % Import g-ig data calculated by A+G 2005 model
Rnum_AG_500k_BPAP_sens_ssp585_dat = importdata('Results/Rnum_AG_-0.5_1myr_AP_LHCsamps_SSP5-85.res'); % Import g-ig data calculated by A+G 2005 model
% Organise imported data
v_AG_500k_BPAP = v_AG_500k_BPAP_dat.data;
t_v_AG_500k_BPAP = t_v_AG_500k_BPAP_dat.data;
Rnum_AG_500k_BPAP = Rnum_AG_500k_BPAP_dat.data;

v_AG_500k_BPAP_sens_nat    = v_AG_500k_BPAP_sens_nat_dat.data(:,2:end);
v_AG_500k_BPAP_sens_ssp119 = v_AG_500k_BPAP_sens_ssp119_dat.data(:,2:end);
v_AG_500k_BPAP_sens_ssp126 = v_AG_500k_BPAP_sens_ssp126_dat.data(:,2:end);
v_AG_500k_BPAP_sens_ssp245 = v_AG_500k_BPAP_sens_ssp245_dat.data(:,2:end);
v_AG_500k_BPAP_sens_ssp370 = v_AG_500k_BPAP_sens_ssp370_dat.data(:,2:end);
v_AG_500k_BPAP_sens_ssp460 = v_AG_500k_BPAP_sens_ssp460_dat.data(:,2:end);
v_AG_500k_BPAP_sens_ssp534 = v_AG_500k_BPAP_sens_ssp534_dat.data(:,2:end);
v_AG_500k_BPAP_sens_ssp585 = v_AG_500k_BPAP_sens_ssp585_dat.data(:,2:end);
t_v_AG_500k_BPAP_sens_nat    = t_v_AG_500k_BPAP_sens_nat_dat.data(:,2:end);
t_v_AG_500k_BPAP_sens_ssp119 = t_v_AG_500k_BPAP_sens_ssp119_dat.data(:,2:end);
t_v_AG_500k_BPAP_sens_ssp126 = t_v_AG_500k_BPAP_sens_ssp126_dat.data(:,2:end);
t_v_AG_500k_BPAP_sens_ssp245 = t_v_AG_500k_BPAP_sens_ssp245_dat.data(:,2:end);
t_v_AG_500k_BPAP_sens_ssp370 = t_v_AG_500k_BPAP_sens_ssp370_dat.data(:,2:end);
t_v_AG_500k_BPAP_sens_ssp460 = t_v_AG_500k_BPAP_sens_ssp460_dat.data(:,2:end);
t_v_AG_500k_BPAP_sens_ssp534 = t_v_AG_500k_BPAP_sens_ssp534_dat.data(:,2:end);
t_v_AG_500k_BPAP_sens_ssp585 = t_v_AG_500k_BPAP_sens_ssp585_dat.data(:,2:end);
Rnum_AG_500k_BPAP_sens_nat    = Rnum_AG_500k_BPAP_sens_nat_dat.data(:,2:end);
Rnum_AG_500k_BPAP_sens_ssp119 = Rnum_AG_500k_BPAP_sens_ssp119_dat.data(:,2:end);
Rnum_AG_500k_BPAP_sens_ssp126 = Rnum_AG_500k_BPAP_sens_ssp126_dat.data(:,2:end);
Rnum_AG_500k_BPAP_sens_ssp245 = Rnum_AG_500k_BPAP_sens_ssp245_dat.data(:,2:end);
Rnum_AG_500k_BPAP_sens_ssp370 = Rnum_AG_500k_BPAP_sens_ssp370_dat.data(:,2:end);
Rnum_AG_500k_BPAP_sens_ssp460 = Rnum_AG_500k_BPAP_sens_ssp460_dat.data(:,2:end);
Rnum_AG_500k_BPAP_sens_ssp534 = Rnum_AG_500k_BPAP_sens_ssp534_dat.data(:,2:end);
Rnum_AG_500k_BPAP_sens_ssp585 = Rnum_AG_500k_BPAP_sens_ssp585_dat.data(:,2:end);


v_SV_21k_BP = v_SV_21k_BP_dat;
v_SV_125k_BP = v_SV_125k_BP_dat;
% gl_sites_rcp45_em_sweden_upper = gl_sites_rcp45_em_sweden_upper_dat.data;
% gl_sites_rcp45_em_finland_upper = gl_sites_rcp45_em_finland_upper_dat.data;

v_SV_21k_BP(:,2) = -(v_SV_21k_BP_dat(:,2));
v_SV_125k_BP(:,2) = -(v_SV_125k_BP_dat(:,2));

time_500k_BPAP = v_AG_500k_BPAP(:,1);
time_21k_BP = -(v_SV_21k_BP(:,1));
time_125k_BP = -(v_SV_125k_BP(:,1));

n_CO2 = size(v_AG_500k_BPAP,2)-1;

num_sens_exp = size(t_v_AG_500k_BPAP_sens_ssp119,2); % Set number of retained sensitivity experiments,90 members in LHC

% Normalise ice volumes to zero for present-day

v_AG_500k_BPAP_norm = v_AG_500k_BPAP;
t_v_AG_500k_BPAP_norm = t_v_AG_500k_BPAP;
v_SV_21k_BP_norm = v_SV_21k_BP;
v_SV_125k_BP_norm = v_SV_125k_BP;

v_AG_500k_BPAP_sens_nat_norm    = v_AG_500k_BPAP_sens_nat;
v_AG_500k_BPAP_sens_ssp119_norm = v_AG_500k_BPAP_sens_ssp119;
v_AG_500k_BPAP_sens_ssp126_norm = v_AG_500k_BPAP_sens_ssp126;
v_AG_500k_BPAP_sens_ssp245_norm = v_AG_500k_BPAP_sens_ssp245;
v_AG_500k_BPAP_sens_ssp370_norm = v_AG_500k_BPAP_sens_ssp370;
v_AG_500k_BPAP_sens_ssp460_norm = v_AG_500k_BPAP_sens_ssp460;
v_AG_500k_BPAP_sens_ssp534_norm = v_AG_500k_BPAP_sens_ssp534;
v_AG_500k_BPAP_sens_ssp585_norm = v_AG_500k_BPAP_sens_ssp585;
t_v_AG_500k_BPAP_sens_nat_norm    = t_v_AG_500k_BPAP_sens_nat;
t_v_AG_500k_BPAP_sens_ssp119_norm = t_v_AG_500k_BPAP_sens_ssp119;
t_v_AG_500k_BPAP_sens_ssp126_norm = t_v_AG_500k_BPAP_sens_ssp126;
t_v_AG_500k_BPAP_sens_ssp245_norm = t_v_AG_500k_BPAP_sens_ssp245;
t_v_AG_500k_BPAP_sens_ssp370_norm = t_v_AG_500k_BPAP_sens_ssp370;
t_v_AG_500k_BPAP_sens_ssp460_norm = t_v_AG_500k_BPAP_sens_ssp460;
t_v_AG_500k_BPAP_sens_ssp534_norm = t_v_AG_500k_BPAP_sens_ssp534;
t_v_AG_500k_BPAP_sens_ssp585_norm = t_v_AG_500k_BPAP_sens_ssp585;


v_AG_500k_BPAP_norm(:,2:9) = v_AG_500k_BPAP(:,2:9) - v_AG_500k_BPAP(501,2);
for col = 2:(n_CO2+1)
    t_v_AG_500k_BPAP_norm(:,col) = t_v_AG_500k_BPAP(:,col) - t_v_AG_500k_BPAP(501,col);
end
v_SV_21k_BP_norm(:,2) = v_SV_21k_BP(:,2) - v_SV_21k_BP(39,2);
v_SV_125k_BP_norm(:,2) = v_SV_125k_BP(:,2) - v_SV_125k_BP(97,2);

for col = 1:num_sens_exp
    v_AG_500k_BPAP_sens_nat_norm(:,col)    = v_AG_500k_BPAP_sens_nat(:,col) - v_AG_500k_BPAP_sens_nat(501,col);
    v_AG_500k_BPAP_sens_ssp119_norm(:,col) = v_AG_500k_BPAP_sens_ssp119(:,col) - v_AG_500k_BPAP_sens_ssp119(501,col);
    v_AG_500k_BPAP_sens_ssp126_norm(:,col) = v_AG_500k_BPAP_sens_ssp126(:,col) - v_AG_500k_BPAP_sens_ssp126(501,col);
    v_AG_500k_BPAP_sens_ssp245_norm(:,col) = v_AG_500k_BPAP_sens_ssp245(:,col) - v_AG_500k_BPAP_sens_ssp245(501,col);
    v_AG_500k_BPAP_sens_ssp370_norm(:,col) = v_AG_500k_BPAP_sens_ssp370(:,col) - v_AG_500k_BPAP_sens_ssp370(501,col);
    v_AG_500k_BPAP_sens_ssp460_norm(:,col) = v_AG_500k_BPAP_sens_ssp460(:,col) - v_AG_500k_BPAP_sens_ssp460(501,col);
    v_AG_500k_BPAP_sens_ssp534_norm(:,col) = v_AG_500k_BPAP_sens_ssp534(:,col) - v_AG_500k_BPAP_sens_ssp534(501,col);
    v_AG_500k_BPAP_sens_ssp585_norm(:,col) = v_AG_500k_BPAP_sens_ssp585(:,col) - v_AG_500k_BPAP_sens_ssp585(501,col);
    t_v_AG_500k_BPAP_sens_nat_norm(:,col)    = t_v_AG_500k_BPAP_sens_nat(:,col) - t_v_AG_500k_BPAP_sens_nat(501,col);
    t_v_AG_500k_BPAP_sens_ssp119_norm(:,col) = t_v_AG_500k_BPAP_sens_ssp119(:,col) - t_v_AG_500k_BPAP_sens_ssp119(501,col);
    t_v_AG_500k_BPAP_sens_ssp126_norm(:,col) = t_v_AG_500k_BPAP_sens_ssp126(:,col) - t_v_AG_500k_BPAP_sens_ssp126(501,col);
    t_v_AG_500k_BPAP_sens_ssp245_norm(:,col) = t_v_AG_500k_BPAP_sens_ssp245(:,col) - t_v_AG_500k_BPAP_sens_ssp245(501,col);
    t_v_AG_500k_BPAP_sens_ssp370_norm(:,col) = t_v_AG_500k_BPAP_sens_ssp370(:,col) - t_v_AG_500k_BPAP_sens_ssp370(501,col);
    t_v_AG_500k_BPAP_sens_ssp460_norm(:,col) = t_v_AG_500k_BPAP_sens_ssp460(:,col) - t_v_AG_500k_BPAP_sens_ssp460(501,col);
    t_v_AG_500k_BPAP_sens_ssp534_norm(:,col) = t_v_AG_500k_BPAP_sens_ssp534(:,col) - t_v_AG_500k_BPAP_sens_ssp534(501,col);
    t_v_AG_500k_BPAP_sens_ssp585_norm(:,col) = t_v_AG_500k_BPAP_sens_ssp585(:,col) - t_v_AG_500k_BPAP_sens_ssp585(501,col);
end

clear *_dat


%% Rescale T data to GSL for LGM (S+V 2010) (T = <0 PI) and future (PRISM3/4) (T = >0 PI)

[LTPI_min_AG_loc(1,1),LTPI_min_AG_loc(1,2)] = min(t_v_AG_500k_BPAP_norm(478:486,2)); % Calculate minimum temperature and row during GL (LGM) from A+G data
LTPI_min_AG_loc(1,2) = LTPI_min_AG_loc(1,2) + 477; % Calculate row for minimum temperature during GL (LGM) from A+G data
[LTPI_min_SV_loc(1,1),LTPI_min_SV_loc(1,2)] = min(v_SV_21k_BP_norm(:,2)); % Calculate minimum SL and row during GL (LGM) from S+V data
[MTPI_max_AG_loc(1,1),MTPI_max_AG_loc(1,2)] = max(t_v_AG_500k_BPAP_norm(501:end,(n_CO2+1))); % Calculate maximum temperature and row during future IG from A+G data
MTPI_max_AG_loc(1,2) = MTPI_max_AG_loc(1,2) + 500; % Calculate row for maximum temperature during future IG from A+G data

LTPI_min_AG = t_v_AG_500k_BPAP_norm(LTPI_min_AG_loc(1,2),1); % Calculate year that minimum temperature occurred during GL (LGM) from A+G data
LTPI_min_SV = v_SV_21k_BP_norm(LTPI_min_SV_loc(1,2),1); % Calculate year that minimum SL occurred during GL (LGM) from S+V data
MTPI_max_AG = t_v_AG_500k_BPAP_norm(MTPI_max_AG_loc(1,2),1); % Calculate year that maximum temperature occurred during future IG from S+V data

LTPI_min_AG(1,2) = LTPI_min_AG_loc(1,1);
LTPI_min_SV(1,2) = LTPI_min_SV_loc(1,1);
MTPI_max_AG(1,2) = MTPI_max_AG_loc(1,1);

maxdiff_AG_LTPI = LTPI_min_AG(1,2);
maxdiff_SV_LTPI = LTPI_min_SV(1,2);
maxdiff_AG_MTPI = 2.66; % SAT increase estimated to accompany SLR from PRISM3D (similar to PRISM4) [Haywood et al 2013]
maxdiff_PRISM_MTPI = 24; % Max SLR from PRISM4 reconstructions [Dowsett et al 2016]

maxdiff_AG_LTPI_scaled = maxdiff_SV_LTPI / maxdiff_AG_LTPI; % Scaled separately depending on state because ice volume not linear
maxdiff_AG_MTPI_scaled = maxdiff_PRISM_MTPI / maxdiff_AG_MTPI;

t_v_AG_500k_BPAP_norm_scaled = t_v_AG_500k_BPAP_norm;
for col = 2:(n_CO2+1)
    for row = 1:length(time_500k_BPAP)
        if t_v_AG_500k_BPAP_norm(row,col) < 0;
            t_v_AG_500k_BPAP_norm_scaled(row,col) = t_v_AG_500k_BPAP_norm_scaled(row,col) * maxdiff_AG_LTPI_scaled;
        elseif t_v_AG_500k_BPAP_norm(row,col) > 0 && t_v_AG_500k_BPAP_norm(row,col) <= maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_norm_scaled(row,col) = t_v_AG_500k_BPAP_norm_scaled(row,col) * maxdiff_AG_MTPI_scaled;
        elseif t_v_AG_500k_BPAP_norm(row,col) > maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_norm_scaled(row,col) = maxdiff_PRISM_MTPI;
        end
    end
end

t_v_AG_500k_BPAP_sens_nat_norm_scaled = t_v_AG_500k_BPAP_sens_nat_norm;
for col = 1:num_sens_exp
    for row = 1:length(time_500k_BPAP)
        if t_v_AG_500k_BPAP_sens_nat_norm(row,col) < 0;
            t_v_AG_500k_BPAP_sens_nat_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_nat_norm_scaled(row,col) * maxdiff_AG_LTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_nat_norm(row,col) > 0 && t_v_AG_500k_BPAP_sens_nat_norm(row,col) <= maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_nat_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_nat_norm_scaled(row,col) * maxdiff_AG_MTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_nat_norm(row,col) > maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_nat_norm_scaled(row,col) = maxdiff_PRISM_MTPI;
        end
    end
end

t_v_AG_500k_BPAP_sens_ssp119_norm_scaled = t_v_AG_500k_BPAP_sens_ssp119_norm;
for col = 1:num_sens_exp
    for row = 1:length(time_500k_BPAP)
        if t_v_AG_500k_BPAP_sens_ssp119_norm(row,col) < 0;
            t_v_AG_500k_BPAP_sens_ssp119_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp119_norm_scaled(row,col) * maxdiff_AG_LTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp119_norm(row,col) > 0 && t_v_AG_500k_BPAP_sens_ssp119_norm(row,col) <= maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp119_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp119_norm_scaled(row,col) * maxdiff_AG_MTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp119_norm(row,col) > maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp119_norm_scaled(row,col) = maxdiff_PRISM_MTPI;
        end
    end
end

t_v_AG_500k_BPAP_sens_ssp126_norm_scaled = t_v_AG_500k_BPAP_sens_ssp126_norm;
for col = 1:num_sens_exp
    for row = 1:length(time_500k_BPAP)
        if t_v_AG_500k_BPAP_sens_ssp126_norm(row,col) < 0;
            t_v_AG_500k_BPAP_sens_ssp126_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp126_norm_scaled(row,col) * maxdiff_AG_LTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp126_norm(row,col) > 0 && t_v_AG_500k_BPAP_sens_ssp126_norm(row,col) <= maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp126_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp126_norm_scaled(row,col) * maxdiff_AG_MTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp126_norm(row,col) > maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp126_norm_scaled(row,col) = maxdiff_PRISM_MTPI;
        end
    end
end

t_v_AG_500k_BPAP_sens_ssp245_norm_scaled = t_v_AG_500k_BPAP_sens_ssp245_norm;
for col = 1:num_sens_exp
    for row = 1:length(time_500k_BPAP)
        if t_v_AG_500k_BPAP_sens_ssp245_norm(row,col) < 0;
            t_v_AG_500k_BPAP_sens_ssp245_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp245_norm_scaled(row,col) * maxdiff_AG_LTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp245_norm(row,col) > 0 && t_v_AG_500k_BPAP_sens_ssp245_norm(row,col) <= maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp245_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp245_norm_scaled(row,col) * maxdiff_AG_MTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp245_norm(row,col) > maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp245_norm_scaled(row,col) = maxdiff_PRISM_MTPI;
        end
    end
end


t_v_AG_500k_BPAP_sens_ssp370_norm_scaled = t_v_AG_500k_BPAP_sens_ssp370_norm;
for col = 1:num_sens_exp
    for row = 1:length(time_500k_BPAP)
        if t_v_AG_500k_BPAP_sens_ssp370_norm(row,col) < 0;
            t_v_AG_500k_BPAP_sens_ssp370_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp370_norm_scaled(row,col) * maxdiff_AG_LTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp370_norm(row,col) > 0 && t_v_AG_500k_BPAP_sens_ssp370_norm(row,col) <= maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp370_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp370_norm_scaled(row,col) * maxdiff_AG_MTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp370_norm(row,col) > maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp370_norm_scaled(row,col) = maxdiff_PRISM_MTPI;
        end
    end
end


t_v_AG_500k_BPAP_sens_ssp460_norm_scaled = t_v_AG_500k_BPAP_sens_ssp460_norm;
for col = 1:num_sens_exp
    for row = 1:length(time_500k_BPAP)
        if t_v_AG_500k_BPAP_sens_ssp460_norm(row,col) < 0;
            t_v_AG_500k_BPAP_sens_ssp460_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp460_norm_scaled(row,col) * maxdiff_AG_LTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp460_norm(row,col) > 0 && t_v_AG_500k_BPAP_sens_ssp460_norm(row,col) <= maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp460_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp460_norm_scaled(row,col) * maxdiff_AG_MTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp460_norm(row,col) > maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp460_norm_scaled(row,col) = maxdiff_PRISM_MTPI;
        end
    end
end


t_v_AG_500k_BPAP_sens_ssp534_norm_scaled = t_v_AG_500k_BPAP_sens_ssp534_norm;
for col = 1:num_sens_exp
    for row = 1:length(time_500k_BPAP)
        if t_v_AG_500k_BPAP_sens_ssp534_norm(row,col) < 0;
            t_v_AG_500k_BPAP_sens_ssp534_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp534_norm_scaled(row,col) * maxdiff_AG_LTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp534_norm(row,col) > 0 && t_v_AG_500k_BPAP_sens_ssp534_norm(row,col) <= maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp534_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp534_norm_scaled(row,col) * maxdiff_AG_MTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp534_norm(row,col) > maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp534_norm_scaled(row,col) = maxdiff_PRISM_MTPI;
        end
    end
end

t_v_AG_500k_BPAP_sens_ssp585_norm_scaled = t_v_AG_500k_BPAP_sens_ssp585_norm;
for col = 1:num_sens_exp
    for row = 1:length(time_500k_BPAP)
        if t_v_AG_500k_BPAP_sens_ssp585_norm(row,col) < 0;
            t_v_AG_500k_BPAP_sens_ssp585_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp585_norm_scaled(row,col) * maxdiff_AG_LTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp585_norm(row,col) > 0 && t_v_AG_500k_BPAP_sens_ssp585_norm(row,col) <= maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp585_norm_scaled(row,col) = t_v_AG_500k_BPAP_sens_ssp585_norm_scaled(row,col) * maxdiff_AG_MTPI_scaled;
        elseif t_v_AG_500k_BPAP_sens_ssp585_norm(row,col) > maxdiff_AG_MTPI;
            t_v_AG_500k_BPAP_sens_ssp585_norm_scaled(row,col) = maxdiff_PRISM_MTPI;
        end
    end
end


%% Plot GSL (Figure 5b from final report)

plot_colours = {
        'k', ...            % natural
        [1 1 0], ...        % SSP1-19 (yellow)
        [0 0.5 0], ...      % SSP1-26 (green)
        [0 0.45 0.7], ...   % SSP2-45 (blueish)
        [1 0.5 0], ...      % SSP3-70 (orange)
        [0 0 0.5] ...       % SSP4-60 (dark blue)
        [0.6 0 0.6], ...    % SSP5-34 (purple)
        [0.8 0 0], ...      % SSP5-85 (red)
    };
sens_plot_colour_BP = [0.7 0.7 0.7]; % Grey for BP sensitivity tests
sens_plot_colour_AP = {
        [0.9 1 0.9], ...        % natural (lighter grey)
        [1 1 0.8], ...            % SSP1-19 (lighter yellow)
        [0.8 0.9 0.8], ...      % SSP1-26 (lighter green)
        [0.8 0.875 0.95], ...   % SSP2-45 (lighter blue)
        [1 0.9 0.8], ...        % SSP3-70 (lighter orange)
        [0.8 0.8 0.95], ...     % SSP4-60 (lighter dark blue)
        [0.9 0.8 0.9], ...      % SSP5-34 (lighter purple)
        [1 0.8 0.8], ...        % SSP5-85 (lighter red)
    };

col_num=[2 3 4 5 6 7 8 9]; % natural, SSP1-19, SSP1-26, SSP2-45, SSP3-70, SSP4-60, SSP5-34, SSP5-85

fw = 29; 
fh = 7.75;
lw = 1;
lw2 = 1.5;
fs = 12; 
fs2 = 10; 
fs3 = 18; 


h = figure('units', 'centimeters', 'position', [3 1 fw fh]);
set(gcf, 'PaperPositionMode', 'auto')

% Plot of climate regimes (via reference ice volumes) and continuous ice volume(middle panel of Figure 3)

p1=subplot(1,1,1); plot((time_500k_BPAP(1:501,1))/1000, t_v_AG_500k_BPAP_norm_scaled(1:501,2), 'Color', 'k', 'LineWidth', lw); 
set(gca, 'FontSize',fs, 'LineWidth', lw); 
xlabel('Time AP (Myr)', 'FontSize',fs)
ylabel('Global sea level (m)', 'FontSize',fs)
axis([-0.5 1 -150 60]);
set(gca, 'xtick', -0.5:0.1:1);
set(gca,'ytick',-150:25:50);
set(gca,'yticklabel',{'-150','','-100','','-50','','0','','50'});
hold on; 
for col_count = 1:num_sens_exp % Loop through sensitivity tests. Here it is 90 members in LHC
    line1a=plot((time_500k_BPAP(1:501,1))/1000, t_v_AG_500k_BPAP_sens_nat_norm_scaled(1:501,col_count), 'Color', sens_plot_colour_BP, 'LineWidth', lw);
    set(get(get(line1a, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
    hold on
end
Ref4 = plot([-0.5 1], [0 0], ':', 'Color', [0.5 0.5 0.5], 'LineWidth', lw); 
set(get(get(Ref4, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
plot((time_500k_BPAP(1:501,1))/1000, t_v_AG_500k_BPAP_norm_scaled(1:501,2), 'Color', 'k', 'LineWidth', lw); 
for col_count = 1:num_sens_exp % Loop through sensitivity tests. Here it is 90 members in LHC
    line10=plot((time_500k_BPAP(502:end,1))/1000, t_v_AG_500k_BPAP_sens_nat_norm_scaled(502:end,col_count), 'Color', sens_plot_colour_AP{1}, 'LineWidth', lw)
    line1a=plot((time_500k_BPAP(502:end,1))/1000, t_v_AG_500k_BPAP_sens_ssp119_norm_scaled(502:end,col_count), 'Color', sens_plot_colour_AP{2}, 'LineWidth', lw);
    line1b=plot((time_500k_BPAP(502:end,1))/1000, t_v_AG_500k_BPAP_sens_ssp126_norm_scaled(502:end,col_count), 'Color', sens_plot_colour_AP{3}, 'LineWidth', lw);
    line1c=plot((time_500k_BPAP(502:end,1))/1000, t_v_AG_500k_BPAP_sens_ssp245_norm_scaled(502:end,col_count), 'Color', sens_plot_colour_AP{4}, 'LineWidth', lw);
    line1d=plot((time_500k_BPAP(502:end,1))/1000, t_v_AG_500k_BPAP_sens_ssp370_norm_scaled(502:end,col_count), 'Color', sens_plot_colour_AP{5}, 'LineWidth', lw);
    line1e=plot((time_500k_BPAP(502:end,1))/1000, t_v_AG_500k_BPAP_sens_ssp460_norm_scaled(502:end,col_count), 'Color', sens_plot_colour_AP{6}, 'LineWidth', lw);
    line1f=plot((time_500k_BPAP(502:end,1))/1000, t_v_AG_500k_BPAP_sens_ssp534_norm_scaled(502:end,col_count), 'Color', sens_plot_colour_AP{7}, 'LineWidth', lw);
    line1g=plot((time_500k_BPAP(502:end,1))/1000, t_v_AG_500k_BPAP_sens_ssp585_norm_scaled(502:end,col_count), 'Color', sens_plot_colour_AP{8}, 'LineWidth', lw);
    set(get(get(line10, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
    set(get(get(line1a, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
    set(get(get(line1b, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
    set(get(get(line1c, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
    set(get(get(line1d, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
    set(get(get(line1e, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
    set(get(get(line1f, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
    set(get(get(line1g, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
    hold on
end
for col_count = 1:8 % Loop through future CO2 scenarios. Here the col_count is different from the previous loop
    col=col_num(col_count); % start from natural (2) to SSP5-85 (9)
    plot((time_500k_BPAP(501:end,1))/1000, t_v_AG_500k_BPAP_norm_scaled(501:end,col), 'Color', plot_colours{col_count}, 'LineWidth', lw); 
end
% Legend for the future CO2 scenarios
leg1 = legend({'natural', 'SSP1-19','SSP1-26','SSP2-45','SSP3-70','SSP4-60','SSP5-34','SSP5-85'}, 'Fontsize', fs);
set(leg1, 'Box', 'off', 'Location', 'northwest', 'Fontsize', fs2);

line4 = plot((time_125k_BP)/1000, v_SV_125k_BP_norm(:,2), '-.', 'Color', [1 0.5 0], 'LineWidth', lw);
line3 = plot((time_21k_BP)/1000, v_SV_21k_BP_norm(:,2), '--', 'Color', plot_colours{1}, 'LineWidth',lw2); 
Ref3 = plot([0 0], [-150 50], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', lw); 
leg2=legend([line3 line4],'LGM-present','LGC');
set(leg2,'Box','off','Location','northwest', 'Fontsize', fs2);
text(-0.078,1.05,'(b)','units','normalized','FontWeight','bold','Fontsize',fs3);
hold off


% Format figure

set(p1,'units','centimeters');

lt=2.25;
bm=2;
wd=26;
ht=5.2;
vgp=1.5;

pos1=get(p1,'Position');
pos1(1)=lt;
pos1(2)=bm;
pos1(3)=wd;
pos1(4)=ht;
set(p1,'Position',pos1);


% %% Save figure
% 
% rez=600; %resolution (dpi) of final graphic
% f=gcf; %f is the handle of the figure you want to export
% figpos=getpixelposition(f); %dont need to change anything here
% resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
% set(f,'paperunits','inches','papersize',figpos(3:4)/resolution,'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
% path='C:\Users\nl6806\OneDrive - University of Bristol\PostDoc\2017-02-15 Posiva + SKB\5. Output\Plots\2018-08-01 Final report\'; %the folder where you want to put the file
% %name='Fig5_Pl_GSL_-500_1myr_AP_test.png'; %what you want the file to be called
% %print(f,fullfile(path,name),'-dpng',['-r',num2str(rez)],'-painters') %save file 
% name='Fig5b.pdf'; %what you want the file to be called
% print(f,fullfile(path,name),'-dpdf',['-r',num2str(rez)],'-painters') %save file 
% 
% 
% % fileName = strcat('C:\Users\nl6806\OneDrive - University of Bristol\PostDoc\2017-02-15 Posiva + SKB\5. Output\Plots\2018-08-01 Final report\Fig5_Pl_GSL_-500_1myr_AP.png');
% % print(h, '-dpng', fileName);
% 
% 
% %% Save data
% 
% % 0 - 1 Myr AP
% 
% data = horzcat(time_500k_BPAP(501:end,1),t_v_AG_500k_BPAP_sens_nat_norm_scaled(501:end,:));
% 
% GSL_text = '% kyr_AP / glob_SL_natural_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_1myr_AP_LHCsamps_nat.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',GSL_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_1myr_AP_LHCsamps_nat.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(501:end,1),t_v_AG_500k_BPAP_sens_rcp26_norm_scaled(501:end,:));
% 
% GSL_text = '% kyr_AP / glob_SL_RCP2.6_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_1myr_AP_LHCsamps_RCP26.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',GSL_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_1myr_AP_LHCsamps_RCP26.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(501:end,1),t_v_AG_500k_BPAP_sens_rcp45_norm_scaled(501:end,:));
% 
% GSL_text = '% kyr_AP / glob_SL_RCP4.5_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_1myr_AP_LHCsamps_RCP45.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',GSL_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_1myr_AP_LHCsamps_RCP45.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(501:end,1),t_v_AG_500k_BPAP_sens_rcp85_norm_scaled(501:end,:));
% 
% GSL_text = '% kyr_AP / glob_SL_RCP8.5_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_1myr_AP_LHCsamps_RCP85.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',GSL_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_1myr_AP_LHCsamps_RCP85.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(vertcat(time_500k_BPAP(501,:),time_500k_BPAP(503:end,:)), vertcat(Rnum_AG_500k_BPAP_sens_nat(501,:),Rnum_AG_500k_BPAP_sens_nat(503:end,:)));
% 
% Rnum_text = '% kyr_AP / Rnum_natural_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_1myr_AP_LHCsamps_nat.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',Rnum_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_1myr_AP_LHCsamps_nat.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(vertcat(time_500k_BPAP(501,:),time_500k_BPAP(503:end,:)), vertcat(Rnum_AG_500k_BPAP_sens_rcp26(501,:),Rnum_AG_500k_BPAP_sens_rcp26(503:end,:)));
% 
% Rnum_text = '% kyr_AP / Rnum_RCP2.6_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_1myr_AP_LHCsamps_RCP26.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',Rnum_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_1myr_AP_LHCsamps_RCP26.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(vertcat(time_500k_BPAP(501,:),time_500k_BPAP(503:end,:)), vertcat(Rnum_AG_500k_BPAP_sens_rcp45(501,:),Rnum_AG_500k_BPAP_sens_rcp45(503:end,:)));
% 
% Rnum_text = '% kyr_AP / Rnum_RCP4.5_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_1myr_AP_LHCsamps_RCP45.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',Rnum_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_1myr_AP_LHCsamps_RCP45.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(vertcat(time_500k_BPAP(501,:),time_500k_BPAP(503:end,:)), vertcat(Rnum_AG_500k_BPAP_sens_rcp85(501,:),Rnum_AG_500k_BPAP_sens_rcp85(503:end,:)));
% 
% Rnum_text = '% kyr_AP / Rnum_RCP8.5_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_1myr_AP_LHCsamps_RCP85.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',Rnum_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_1myr_AP_LHCsamps_RCP85.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% % -500 - 0 Myr AP
% 
% data = horzcat(time_500k_BPAP(1:501,1),t_v_AG_500k_BPAP_sens_nat_norm_scaled(1:501,:));
% 
% GSL_text = '% kyr_AP / glob_SL_natural_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_-500kyr_AP_LHCsamps_nat.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',GSL_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_-500kyr_AP_LHCsamps_nat.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(1:501,1),t_v_AG_500k_BPAP_sens_rcp26_norm_scaled(1:501,:));
% 
% GSL_text = '% kyr_AP / glob_SL_RCP2.6_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_-500kyr_AP_LHCsamps_RCP26.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',GSL_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_-500kyr_AP_LHCsamps_RCP26.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(1:501,1),t_v_AG_500k_BPAP_sens_rcp45_norm_scaled(1:501,:));
% 
% GSL_text = '% kyr_AP / glob_SL_RCP4.5_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_-500kyr_AP_LHCsamps_RCP45.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',GSL_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_-500kyr_AP_LHCsamps_RCP45.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(1:501,1),t_v_AG_500k_BPAP_sens_rcp85_norm_scaled(1:501,:));
% 
% GSL_text = '% kyr_AP / glob_SL_RCP8.5_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_-500kyr_AP_LHCsamps_RCP85.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',GSL_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\global_sea_level_AG_-500kyr_AP_LHCsamps_RCP85.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(1:501,:), Rnum_AG_500k_BPAP_sens_nat(1:501,:));
% 
% Rnum_text = '% kyr_AP / Rnum_natural_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_-500kyr_AP_LHCsamps_nat.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',Rnum_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_-500kyr_AP_LHCsamps_nat.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(1:501,:), Rnum_AG_500k_BPAP_sens_rcp26(1:501,:));
% 
% Rnum_text = '% kyr_AP / Rnum_RCP2.6_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_-500kyr_AP_LHCsamps_RCP26.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',Rnum_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_-500kyr_AP_LHCsamps_RCP26.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(1:501,:), Rnum_AG_500k_BPAP_sens_rcp45(1:501,:));
% 
% Rnum_text = '% kyr_AP / Rnum_RCP4.5_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_-500kyr_AP_LHCsamps_RCP45.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',Rnum_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_-500kyr_AP_LHCsamps_RCP45.res',data,'-append','newline','pc','delimiter',' ','precision',4);
% 
% 
% data = horzcat(time_500k_BPAP(1:501,:), Rnum_AG_500k_BPAP_sens_rcp85(1:501,:));
% 
% Rnum_text = '% kyr_AP / Rnum_RCP8.5_for_90_retained_LHC_sample_sets';
% 
% fName='C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_-500kyr_AP_LHCsamps_RCP85.res';
% fileID=fopen(fName,'w');
% fprintf(fileID,'%s\n',Rnum_text);
% fclose(fileID);
% dlmwrite('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\2018-08-01 Final report\\Results\\Rnum_AG_-500kyr_AP_LHCsamps_RCP85.res',data,'-append','newline','pc','delimiter',' ','precision',4);

