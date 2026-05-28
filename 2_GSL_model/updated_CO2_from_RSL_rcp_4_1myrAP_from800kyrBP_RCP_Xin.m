%%%% CALCULATE RESPONSE OF CO2 TO SEA LEVEL (DURING GLACIAL PERIODS) %%%%
% Reduces CO2 concentration during glacial periods based on linear %
% regression between CO2 and temp (deuterium) from ice cores for 800 - 0 Kyr BP %

clear

% Load data

CO2_data_800k_BP_dat = importdata('ForcingData/CO2_composite_-0.8-0ma.res'); % Import past CO2 trajectory data
CO2_data_1m_AP_rcp26_dat = importdata('ForcingData/CO2_data_rcp26_0-1ma.res'); % Import future CO2 trajectory data
CO2_data_1m_AP_rcp45_dat = importdata('ForcingData/CO2_data_rcp45_0-1ma_Xin.res'); % Import future CO2 trajectory data
CO2_data_1m_AP_rcp6_dat = importdata('ForcingData/CO2_data_rcp6_0-1ma.res'); % Import future CO2 trajectory data
CO2_data_1m_AP_rcp85_dat = importdata('ForcingData/CO2_data_rcp85_0-1ma_Xin.res'); % Import future CO2 trajectory data

T_v_AG_500k_BPAP_dat = importdata('Results/RCPs_Xin/temp_v_AG_-0.5_1myr_AP.Corr_Xin.res'); % Import temperature data (calculated from ice volume) calculated by A+G 2005 model

d18O_data_800k_BP_dat = importdata('ForcingData/d18O_LisieckiRaymo_-0.8-0ma.res'); % Import past d18O data

% CO2_data_800k_BP_dat = importdata('C:\\Users\\nl6806\\OneDrive - University of Bristol\\PostDoc\\2017-02-15 Posiva + SKB\\2. Global climate histories\\2. Estimates of ice volume\\Global conceptual model\\Forcing data\\CO2_composite_-800-0kyr.res'); % Import CO2 data for last 800 kyr (composite record)
T_data_800k_BP_dat = importdata('ForcingData/deut_temp_Jouzel_-800-0kyr.res'); % Import temperature (deuterium) data for last 800 kyr [Jouzel et al 2007]


CO2_data_800k_BP = CO2_data_800k_BP_dat.data;
CO2_1m_AP(:,1) = CO2_data_1m_AP_rcp26_dat.data(:,1);
CO2_1m_AP(1,1)=0.1; % Change first year of anthropogenic forcing to after persent-day
CO2_1m_AP(:,2) = vertcat(repmat(280,length(CO2_1m_AP(:,1)),1));
CO2_1m_AP(:,3) = CO2_data_1m_AP_rcp26_dat.data(:,2); % Extract CO2 data for next 500 kyr
CO2_1m_AP(:,4) = CO2_data_1m_AP_rcp45_dat.data(:,2); % Extract CO2 data for next 500 kyr
CO2_1m_AP(:,5) = CO2_data_1m_AP_rcp6_dat.data(:,2); % Extract CO2 data for next 500 kyr
CO2_1m_AP(:,6) = CO2_data_1m_AP_rcp85_dat.data(:,2); % Extract CO2 data for next 500 kyr
CO2_1m_AP_PI=[0,280,280,280,280,280]; % Add PI values
CO2_1m_AP = vertcat(CO2_1m_AP_PI,CO2_1m_AP);
ne = 5;

T_v_AG_1m_BPAP = T_v_AG_500k_BPAP_dat.data(501:end,:);

orig_d18O_800k_BP = d18O_data_800k_BP_dat.data(:,1:2);

orig_CO2_800k_BP = flipud(CO2_data_800k_BP_dat.data); % Extract CO2 data for last 800 kyr
orig_T_800k_BP = flipud(T_data_800k_BP_dat.data); % Extract temp data for last 800 kyr
%orig_CO2_800k_BP(:,1) = (-orig_CO2_800k_BP(:,1))./1000; 
orig_CO2_800k_BP(:,1) = orig_CO2_800k_BP(:,1); %Xin: Don't change unit here'
orig_T_800k_BP(:,1) = (-orig_T_800k_BP(:,1))./1000;

time_800k_BP = (-800:0)'; % Time data for last 800 kyr'
time_800k_BP_every10 = (-800:0.01:0)'; % Time data for last 800 kyr'


orig_CO2_800k_BP(end+1,1:2) = [0,280]; % Create data point for 0 kyr BP
orig_T_800k_BP(end+1,1:2) = [0,0]; % Create data point for 0 kyr BP

clear *_dat


%% Check for duplicates

% a = time_800k_BP_d18O;
% 
% num = 1;
% 
% for row = 2:length(a)
%     b = a(row,1) - a(row-1,1);
%     if b == 0
%         duplicate(num,1) = row;
%         num = num + 1;
%     else
%         disp 'no duplicate'
%     end
% end


%% Interpolate past CO2 and temperature data to give concentration for every 100 yr

d18O_800k_BP = time_800k_BP_every10;
CO2_800k_BP = time_800k_BP_every10;
T_800k_BP = time_800k_BP_every10;

d18O_800k_BP(:,2) = interp1(orig_d18O_800k_BP(:,1), orig_d18O_800k_BP(:,2), time_800k_BP_every10); % Interpolate d18O data for last 800 kyr to full 800 kyr BP time series
CO2_800k_BP(:,2) = interp1(orig_CO2_800k_BP(:,1), orig_CO2_800k_BP(:,2), time_800k_BP_every10); % Interpolate CO2 data for last 800 kyr to full 800 kyr BP time series
T_800k_BP(:,2) = interp1(orig_T_800k_BP(:,1), orig_T_800k_BP(:,2), time_800k_BP_every10); % Interpolate T data for last 800 kyr to full 800 kyr BP time series

%figure; plot(orig_d18O_800k_BP(:,1), orig_d18O_800k_BP(:,2)); axis([-800 0 3 5.5]);
%figure; plot(d18O_800k_BP(:,1), d18O_800k_BP(:,2)); axis([-800 0 3 5.5]);

%figure; plot(orig_CO2_800k_BP(:,1), orig_CO2_800k_BP(:,2)); axis([-800 0 150 300]);
%figure; plot(CO2_800k_BP(:,1), CO2_800k_BP(:,2)); axis ([-800 0 150 300]);

%figure; plot(orig_temp_800k_BP(:,1), orig_temp_800k_BP(:,2)); axis([-800 0 -12 6]);
%figure; plot(temp_800k_BP(:,1), temp_800k_BP(:,2)); axis([-8000 0 -12 6]);


%% Convert ice volumes to temperature

T_pre_ind = 0; % deg C
T_lgm = -4; % deg C


% d18O data

d18O_pre_ind = orig_d18O_800k_BP(end,2);
d18O_lgm = orig_d18O_800k_BP(683,2);

d18O_diff = d18O_lgm - d18O_pre_ind;
d18O_diff_scaled = d18O_diff / T_lgm;

T_d18O_800k_BP(:,1) = time_800k_BP_every10;
orig_T_d18O_800k_BP(:,1) = orig_d18O_800k_BP(:,1);

for row = 1:length(d18O_800k_BP(:,1))
    T_d18O_800k_BP(row,2) = (d18O_800k_BP(row,2) - d18O_pre_ind) / d18O_diff_scaled;
end

for row = 1:length(orig_d18O_800k_BP(:,1))
    orig_T_d18O_800k_BP(row,2) = (orig_d18O_800k_BP(row,2) - d18O_pre_ind) / d18O_diff_scaled;
end

%figure; plot(orig_T_d18O_800k_BP(:,1), orig_T_d18O_800k_BP(:,2)); axis([-800 0 -6.5 1]);
%figure; plot(T_d18O_800k_BP(:,1), T_d18O_800k_BP(:,2)); axis([-800 0 -6.5 1]);


%% Fit linear model to paleo CO2 and temperature data

% Fit linear regression model

%figure; plot(T_800k_BP(:,2), CO2_800k_BP(:,2),'o');
%figure; plot(T_d18O_800k_BP(:,2), CO2_800k_BP(:,2),'o');

CO2_pre_ind = CO2_800k_BP(end,2);

anom_CO2_800k_BP = CO2_800k_BP;
anom_CO2_800k_BP(:,2) = CO2_pre_ind - CO2_800k_BP(:,2);

%figure; plot(T_d18O_800k_BP(:,2), anom_CO2_800k_BP(:,2),'o');

X=T_d18O_800k_BP(:,2);
y=anom_CO2_800k_BP(:,2);

model_l=LinearModel.fit(X,y);

Xnew=X;
ypred_l=predict(model_l,Xnew);


% Calculate residuals

ypred_l_resid=ypred_l-anom_CO2_800k_BP(:,2);

figure; plot(X, y,'o',Xnew, ypred_l,'^r');


%% Use linear model to calculate 

CO2_1m_AP_updated = CO2_1m_AP(:,1);

for col = 2:(ne+1);
    for row = 1:length(T_v_AG_1m_BPAP(:,1));
        if T_v_AG_1m_BPAP(row,col) < 0 % If glacial conditions apply CO2 reduction based on linear model
            X1 = T_v_AG_1m_BPAP(row,col);
            y1pred_l = predict(model_l,X1);
            CO2_1m_AP_updated(row,col) = CO2_1m_AP(row,col)-y1pred_l;
        else % If interglacial conditions leave CO2 as predicted by RF
            CO2_1m_AP_updated(row,col) = CO2_1m_AP(row,col);
        end
    end
end


%% Plot of atmospheric CO2 concentration (top panel of Figure 3 of A+G 05)

plot_colours = {[0.65 0.16 0.16], [1 0.5 0], 'k', 'g', 'r', 'b'}; % Set colours for scenarios

fw = 29; 
fh = 14.5;
lw = 1;
fs = 16; 
fs2 = 10; 


h = figure('units', 'centimeters', 'position', [3 1 fw fh]);
set(gcf, 'PaperPositionMode', 'auto')

p1 = subplot(2,1,1); line1 = plot(CO2_800k_BP(:,1), CO2_800k_BP(:,2), 'Color', [1 0.5 0], 'LineWidth', lw);
set(get(get(line1, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
hold on
for col = 2:(ne+1) % Loop through future CO2 scenarios
    plot(CO2_1m_AP(:,1), CO2_1m_AP(:,col), '-', 'Color', plot_colours{col}, 'LineWidth', lw); 
end
set(gca, 'FontSize', fs, 'LineWidth', lw);
ylabel('pCO2 (ppmv)', 'Fontsize', fs)
axis([-500 1000 0 1200]); 
set(gca, 'xtick', -500:100:1000);
set(gca, 'ytick', 0:200:1200);
Ref1 = plot([0 0], [0 1200], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', lw); 
leg1 = legend({'Natural', 'RCP2.6', 'RCP4.5', 'RCP6', 'RCP8.5'}, 'Fontsize', fs);
set(leg1, 'Box', 'off', 'Location', 'northeast', 'Fontsize', fs);

p2 = subplot(2,1,2); line1 = plot(CO2_800k_BP(:,1), CO2_800k_BP(:,2), 'Color', [1 0.5 0], 'LineWidth', lw);
set(get(get(line1, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off')
hold on
for col = 2:(ne+1) % Loop through future CO2 scenarios
    plot(CO2_1m_AP_updated(:,1), CO2_1m_AP_updated(:,col), '-', 'Color', plot_colours{col}, 'LineWidth', lw); 
end
set(gca, 'FontSize', fs, 'LineWidth', lw);
xlabel('Time (kyr)', 'Fontsize', fs)
ylabel('pCO2 (ppmv)', 'Fontsize', fs)
axis([-500 1000 0 1200]); 
set(gca, 'xtick', -500:100:1000);
set(gca, 'ytick', 0:200:1200);
Ref1 = plot([0 0], [0 1200], '-', 'Color', [0.5 0.5 0.5], 'LineWidth', lw); 
set(leg1, 'Box', 'off', 'Location', 'northwest', 'Fontsize', fs);



% Format figure

set(p1,'units','centimeters');
set(p2,'units','centimeters');

lt=2.25;
bm=2;
wd=26;
ht=5.2;
vgp=1.5;

pos1=get(p1,'Position');
pos1(1)=lt;
pos1(2)=bm+(ht*1)+(vgp*1);
pos1(3)=wd;
pos1(4)=ht;
set(p1,'Position',pos1);

pos2=get(p2,'Position');
pos2(1)=lt;
pos2(2)=bm;
pos2(3)=wd;
pos2(4)=ht;
set(p2,'Position',pos2);


% %% Save figure
% 
% fileName = strcat('C:\Users\nl6806\OneDrive - University of Bristol\PostDoc\2017-02-15 Posiva + SKB\2. Global climate histories\7. Plots\Global conceptual model\2018-08-01 Final report\Pl_updated_CO2_from_SL_rcp_4_1myr_AP.png');
% print(h, '-dpng', fileName);
% 
data= CO2_1m_AP_updated;

CO2_text = '% kyr_AP / CO2_natural / CO2_natural_rcp2.6 / CO2_natural_rcp4.5 / CO2_natural_rcp6 / CO2_natural_rcp8.5';

fName='updated_CO2_from_SL_1myr_AP_from800kyrBP—RCP_Xin.res';
fileID=fopen(fName,'w');
fprintf(fileID,'%s\n',CO2_text);
fclose(fileID);
dlmwrite(fName,data,'-append','newline','pc','delimiter',' ','precision',4);

data_orig=CO2_1m_AP;
fName_orig='original_CO2_1myr_AP_from800kyrBP_RCP_Xin.res';
fileID_orig=fopen(fName_orig,'w');
fprintf(fileID_orig,'%s\n',CO2_text);
fclose(fileID_orig);
dlmwrite(fName_orig,data_orig,'-append','newline','pc','delimiter',' ','precision',4);