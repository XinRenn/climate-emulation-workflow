% load_forcing_data.m 


%% Load insolation data
% Insolation data (Laskar 2004 June insolation at 65degN)
insol_data_dat = importdata('ForcingData/Insol_Laskar_jul_65N_0.5-1ma.res');
% Extract insolation data for last and next 500 kyr (double 0 as one of the CO2 values is at 0.1 kyr to capture anthropogenic max)
insol_data_500k_BPAP = vertcat(insol_data_dat.data(1:501,2),insol_data_dat.data(501,2),insol_data_dat.data(502:end,2));

% Normalize insolation to zero mean and unit variance
insol_mean_500k_BPAP = mean(insol_data_500k_BPAP); % Calculate mean of insolation data
insol_mean_zero_500k_BPAP = insol_data_500k_BPAP - insol_mean_500k_BPAP; % Normalize insolation data to zero mean
insol_var_500k_BPAP = sqrt(mean((insol_mean_zero_500k_BPAP-(mean(insol_mean_zero_500k_BPAP))).^2)); % Calculate standard deviation of insolation data
insol_var_zero_500k_BPAP = insol_mean_zero_500k_BPAP / insol_var_500k_BPAP ; % Normalize insolation data to zero variance


%% Load CO2 data
% Load CO2 trajectory data
CO2_data_natural_dat = importdata('ForcingData/CO2_data_Petitetal_-0.4-0ma.res');
CO2_data_rcp26_dat = importdata('ForcingData/CO2_data_rcp26_0-1ma.res');
CO2_data_rcp45_dat = importdata('ForcingData/CO2_data_rcp45_0-1ma.res');
CO2_data_rcp6_dat = importdata('ForcingData/CO2_data_rcp6_0-1ma.res');
CO2_data_rcp85_dat = importdata('ForcingData/CO2_data_rcp85_0-1ma.res');

% Extract CO2 trajectory data
CO2_500k_BP_natural(:,1) = CO2_data_natural_dat.data(:,2);
CO2_1m_AP_dat(:,1) = CO2_data_rcp26_dat.data(:,2);
CO2_1m_AP_dat(:,2) = CO2_data_rcp45_dat.data(:,2);
CO2_1m_AP_dat(:,3) = CO2_data_rcp6_dat.data(:,2);
CO2_1m_AP_dat(:,4) = CO2_data_rcp85_dat.data(:,2);


%% Load d18O data
% Past d18O data
d18O_data_dat = importdata('ForcingData/d18O_LisieckiRaymo_-0.5-0ma.res');
d18O_data = d18O_data_dat.data(:,2);


%% Load time data
% Setup time
time_500k_BP_natural = CO2_data_natural_dat.data(:,1); % Extract time data for last 500 kyr from natural data
time_500k_BP = insol_data_dat.data(1:501,1); % Extract time data for last 500 kyr
time_1m_AP = insol_data_dat.data(501:end,1); % Extract time data for next 500 kyr
time_1m_AP(1,1)=0.1; % Change first year of anthropogenic forcing to after persent-day
time_500k_BPAP = vertcat(insol_data_dat.data(1:501,1),0.1,insol_data_dat.data(502:end,1)); % Extract time data for last 500 kyr and next 500 kyr


%% Interpolate natural past CO2 data to give concentration for every 1 kyr
% Create data point for 1 kyr BP and 0kyr BP both at pre-industrial CO2
time_500k_BP_natural(end+1,1) = -1;
CO2_500k_BP_natural(end+1,1) = 280;
time_500k_BP_natural(end+1,1) = 0;
CO2_500k_BP_natural(end+1,1) = 280;

% Interpolate natural CO2 data to full 500 kyr BP time series
CO2_500k_BP_dat = interp1(time_500k_BP_natural, CO2_500k_BP_natural, time_500k_BP);

CO2_500k_BP = repmat(CO2_500k_BP_dat, 1, 5); % Create time series of CO2 concentrations for time period
CO2_500k_BP(isnan(CO2_500k_BP)) = 280;
CO2_conc_1m_AP = 280; % Atmospheric CO2 concentration for next 500 kyr (ppm)
CO2_1m_AP = horzcat(repmat(CO2_conc_1m_AP(1,1), length(time_1m_AP),1), CO2_1m_AP_dat); % Create time series of CO2 concentrations for time period
CO2_500k_BPAP = vertcat(CO2_500k_BP, CO2_1m_AP);


