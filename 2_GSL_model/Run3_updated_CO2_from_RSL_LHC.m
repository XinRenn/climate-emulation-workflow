%%%% CALCULATE RESPONSE OF CO2 TO SEA LEVEL (DURING GLACIAL PERIODS) %%%%
% Reduces CO2 concentration during glacial periods based on linear
% regression between CO2 and temp (deuterium) from ice cores for 800-0 kyr BP.
% Processes all LHC ensemble members.

clear

% Option to save figure
savefig = 1;

% ===== CONFIGURATION — edit this block to change scenarios/paths =====
scenario_names = {'SSP1-19', 'SSP1-26', 'SSP2-45', 'SSP3-70', 'SSP5-85', '10000pgc'};
co2_path     = '../1_CO2_model/SSP/concentration_ppmv/';
forcing_path = 'ForcingData/';
lhc_path     = 'results/LHCsamps/';
results_path = 'results/updated_CO2_LHS/';
plots_path   = 'Plots/';
Fig_name     = 'CO2_updated_from_RSL';
nat_colour   = 'k';
ssp_colours  = {[1 1 0], [0 0.5 0], [0 0.45 0.7], [1 0.5 0], [0.8 0 0], [0.5 0 0]};
% ======================================================================
n_ssp = length(scenario_names);
ne = n_ssp + 1;  % natural + SSPs (col2=nat, cols 3..ne+1=SSPs)
% plot_colours is col-indexed to match CO2_1m_AP columns: {2}=nat, {3..ne+1}=SSPs
plot_colours = [{'dummy', nat_colour}, ssp_colours];


%% Load data

CO2_data_800k_BP_dat = importdata([forcing_path, 'CO2_composite_-0.8-0ma.res']);
CO2_data_1m_AP_dat = cell(1, n_ssp);
for s = 1:n_ssp
    CO2_data_1m_AP_dat{s} = importdata([co2_path, 'CO2_data_', scenario_names{s}, '_0-1ma.res']);
end

T_v_dat_nat = importdata([lhc_path, 'temp_v_AG_-0.5_1myr_AP_LHCsamps_nat.Corr.res']);
T_v_dat_ssp = cell(1, n_ssp);
for s = 1:n_ssp
    T_v_dat_ssp{s} = importdata([lhc_path, 'temp_v_AG_-0.5_1myr_AP_LHCsamps_', scenario_names{s}, '.Corr.res']);
end

d18O_data_800k_BP_dat = importdata([forcing_path, 'd18O_LisieckiRaymo_-0.8-0ma.res']);
T_data_800k_BP_dat    = importdata([forcing_path, 'deut_temp_Jouzel_-800-0kyr.res']);


CO2_data_800k_BP = CO2_data_800k_BP_dat.data;
CO2_1m_AP(:,1) = CO2_data_1m_AP_dat{1}.data(:,1);
CO2_1m_AP(1,1) = 0.1;  % Change first year of anthropogenic forcing to after present-day
CO2_1m_AP(:,2) = repmat(280, length(CO2_1m_AP(:,1)), 1);  % natural (constant pre-industrial)
for s = 1:n_ssp
    CO2_1m_AP(:, s+2) = CO2_data_1m_AP_dat{s}.data(:,2);
end
CO2_1m_AP_PI = [0, repmat(280, 1, ne)];  % PI values: time + nat + all SSPs = ne+1 elements
CO2_1m_AP = vertcat(CO2_1m_AP_PI, CO2_1m_AP);

T_v_AG_1m_BPAP_nat = T_v_dat_nat.data(501:end,:);
T_v_AG_1m_BPAP_ssp = cell(1, n_ssp);
for s = 1:n_ssp
    T_v_AG_1m_BPAP_ssp{s} = T_v_dat_ssp{s}.data(501:end,:);
end

orig_d18O_800k_BP = d18O_data_800k_BP_dat.data(:,1:2);

orig_CO2_800k_BP = flipud(CO2_data_800k_BP_dat.data);

disp(['first few rows of orig_CO2_800k_BP before unit change:']);
disp(orig_CO2_800k_BP(end-4:end,:));

orig_T_800k_BP = flipud(T_data_800k_BP_dat.data);
orig_CO2_800k_BP(:,1) = orig_CO2_800k_BP(:,1);  % Xin: Don't change unit here
orig_T_800k_BP(:,1) = (-orig_T_800k_BP(:,1))./1000;

time_800k_BP = (-800:0)';
time_800k_BP_every10 = (-800:0.01:0)';

orig_CO2_800k_BP(end+1,1:2) = [0,280];
orig_T_800k_BP(end+1,1:2) = [0,0];

clear *_dat


%% Interpolate past CO2 and temperature data to every 100 yr

d18O_800k_BP = time_800k_BP_every10;
CO2_800k_BP  = time_800k_BP_every10;
T_800k_BP    = time_800k_BP_every10;

d18O_800k_BP(:,2) = interp1(orig_d18O_800k_BP(:,1), orig_d18O_800k_BP(:,2), time_800k_BP_every10);
CO2_800k_BP(:,2)  = interp1(orig_CO2_800k_BP(:,1),  orig_CO2_800k_BP(:,2),  time_800k_BP_every10);
T_800k_BP(:,2)    = interp1(orig_T_800k_BP(:,1),    orig_T_800k_BP(:,2),    time_800k_BP_every10);

disp(['Number of NaN in orig_CO2_800k_BP1: ', num2str(sum(isnan(orig_CO2_800k_BP(:,1))))]);
disp(['Number of NaN in orig_CO2_800k_BP2: ', num2str(sum(isnan(orig_CO2_800k_BP(:,2))))]);
disp(['Number of NaN in CO2_800k_BP: ',       num2str(sum(isnan(CO2_800k_BP(:,2))))]);


%% Convert d18O to temperature

T_pre_ind = 0;   % deg C
T_lgm     = -4;  % deg C

d18O_pre_ind = orig_d18O_800k_BP(end,2);
d18O_lgm     = orig_d18O_800k_BP(683,2);

d18O_diff        = d18O_lgm - d18O_pre_ind;
d18O_diff_scaled = d18O_diff / T_lgm;

T_d18O_800k_BP(:,1)     = time_800k_BP_every10;
orig_T_d18O_800k_BP(:,1) = orig_d18O_800k_BP(:,1);

for row = 1:length(d18O_800k_BP(:,1))
    T_d18O_800k_BP(row,2) = (d18O_800k_BP(row,2) - d18O_pre_ind) / d18O_diff_scaled;
end

for row = 1:length(orig_d18O_800k_BP(:,1))
    orig_T_d18O_800k_BP(row,2) = (orig_d18O_800k_BP(row,2) - d18O_pre_ind) / d18O_diff_scaled;
end


%% Fit linear model between paleo CO2 anomaly and temperature

CO2_pre_ind = CO2_800k_BP(end,2);

anom_CO2_800k_BP = CO2_800k_BP;
anom_CO2_800k_BP(:,2) = CO2_pre_ind - CO2_800k_BP(:,2);

X = T_d18O_800k_BP(:,2);
y = anom_CO2_800k_BP(:,2);

model_l = LinearModel.fit(X, y);

Xnew    = X;
ypred_l = predict(model_l, Xnew);

ypred_l_resid = ypred_l - anom_CO2_800k_BP(:,2);

figure; plot(X, y, 'o', Xnew, ypred_l, '^r');


%% Apply linear model to update future CO2 for each LHC member

CO2_1m_AP_updated = zeros(length(CO2_1m_AP(:,1)), ne+1, length(T_v_AG_1m_BPAP_nat(1,:)));
for mem = 1:length(T_v_AG_1m_BPAP_nat(1,:))
    CO2_1m_AP_updated(:,1,mem) = CO2_1m_AP(:,1);
end

T_v_AG_1m_BPAP = zeros(length(T_v_AG_1m_BPAP_nat(:,1)), ne+1, length(T_v_AG_1m_BPAP_nat(1,:)));
T_v_AG_1m_BPAP(:,2,:) = T_v_AG_1m_BPAP_nat(:,:);
for s = 1:n_ssp
    T_v_AG_1m_BPAP(:, s+2, :) = T_v_AG_1m_BPAP_ssp{s}(:,:);
end

for col = 2:(ne+1)
    for row = 1:length(T_v_AG_1m_BPAP(:,1,1))
        for mem = 1:length(T_v_AG_1m_BPAP(1,1,:))
            if T_v_AG_1m_BPAP(row,col,mem) < 0  % glacial: apply CO2 reduction
                X1 = T_v_AG_1m_BPAP(row,col,mem);
                y1pred_l = predict(model_l, X1);
                CO2_1m_AP_updated(row,col,mem) = CO2_1m_AP(row,col) - y1pred_l;
            else  % interglacial: leave CO2 as-is
                CO2_1m_AP_updated(row,col,mem) = CO2_1m_AP(row,col);
            end
        end
    end
end


%% Plot atmospheric CO2: original (top) and sea-level corrected (bottom)

fw = 29;
fh = 14.5;
lw = 1;
fs = 16;

leg_labels = [{'Natural'}, cellfun(@(s) strrep(s, 'pgc', 'PGC'), scenario_names, 'UniformOutput', false)];

h = figure('units', 'centimeters', 'position', [3 1 fw fh]);
set(gcf, 'PaperPositionMode', 'auto')

p1 = subplot(2,1,1);
line1 = plot(CO2_800k_BP(:,1), CO2_800k_BP(:,2), 'Color', [1 0.5 0], 'LineWidth', lw);
set(get(get(line1, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
hold on
for col = 2:(ne+1)
    plot(CO2_1m_AP(:,1), CO2_1m_AP(:,col), '-', 'Color', plot_colours{col}, 'LineWidth', lw);
end
set(gca, 'FontSize', fs, 'LineWidth', lw);
ylabel('pCO2 (ppmv)', 'Fontsize', fs)
axis([-500 1000 0 1200]);
set(gca, 'xtick', -500:100:1000);
set(gca, 'ytick', 0:200:1200);
plot([0 0], [0 1200], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', lw);
leg1 = legend(leg_labels, 'Box', 'off', 'Location', 'northeast', 'Fontsize', fs-2);

p2 = subplot(2,1,2);
line1 = plot(CO2_800k_BP(:,1), CO2_800k_BP(:,2), 'Color', [1 0.5 0], 'LineWidth', lw);
set(get(get(line1, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
hold on
for mem = 1:length(CO2_1m_AP_updated(1,1,:))
    for col = 2:(ne+1)
        plot(CO2_1m_AP_updated(:,1,mem), CO2_1m_AP_updated(:,col,mem), '-', 'Color', plot_colours{col}, 'LineWidth', lw);
    end
end
set(gca, 'FontSize', fs, 'LineWidth', lw);
xlabel('Time (kyr)', 'Fontsize', fs)
ylabel('pCO2 (ppmv)', 'Fontsize', fs)
axis([-500 1000 0 1200]);
set(gca, 'xtick', -500:100:1000);
set(gca, 'ytick', 0:200:1200);
plot([0 0], [0 1200], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', lw);
legend(leg_labels, 'Box', 'off', 'Location', 'northwest', 'Fontsize', fs-2);

% Format figure layout
set(p1, 'units', 'centimeters');
set(p2, 'units', 'centimeters');
lt = 2.25;  bm = 2;  wd = 26;  ht = 5.2;  vgp = 1.5;
pos1 = get(p1, 'Position');
pos1(1) = lt;  pos1(2) = bm + ht + vgp;  pos1(3) = wd;  pos1(4) = ht;
set(p1, 'Position', pos1);
pos2 = get(p2, 'Position');
pos2(1) = lt;  pos2(2) = bm;  pos2(3) = wd;  pos2(4) = ht;
set(p2, 'Position', pos2);

if savefig
    if ~exist(plots_path, 'dir'); mkdir(plots_path); end
    print(h, '-dpng', [plots_path, Fig_name, '.png']);
end


%% Save updated CO2 per LHC member

CO2_text = ['% kyr_AP / CO2_natural', sprintf(' / CO2_%s', scenario_names{:})];
data = CO2_1m_AP_updated;

if ~exist(results_path, 'dir'); mkdir(results_path); end
for mem = 1:length(data(1,1,:))
    fName = sprintf([results_path, 'updated_CO2_from_SL_1myr_AP_from500kyrBP.%d.res'], mem);
    fileID = fopen(fName, 'w');
    fprintf(fileID, '%s\n', CO2_text);
    fclose(fileID);
    dlmwrite(fName, data(:,:,mem), '-append', 'newline', 'pc', 'delimiter', ' ', 'precision', 5);
end
