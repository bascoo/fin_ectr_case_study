clear all
clc
format compact

%% Load Data
%get the values in the Excel using xlsread.
table           = readtable('netflix_resampled_5minutes.csv');

load('realized_kernel.csv');  % load realized kernel
%load('datelist_all_trading_days.mat'); % stores 'Full_date_list'

datetime        = char(table2array(table(:,1)));
dates           = datetime(:,1:10);
times           = datetime(:,11:19);
dates           = char_to_string(dates);
times           = char_to_string(times);
netflixPrice    = table2array(table(:,2));
dt              = table2array(table(:,1));
clear table % reduce workspace burden

%%

p               = log(netflixPrice); % log price
r               = diff(p);           % log return 
r_adjusted      = [0; r];            % first return = 0 so array sizes match
mean_r          = mean(r);
y               = r - mean_r;

figure()
subplot(2,1,1)
plot(dt,p, 'b')
xlabel('Date')
ylabel('Log price')
title('Log prices of Netflix')
subplot(2,1,2)
plot(dt(2:end),r, 'r')
xlabel('Date')
ylabel('Log return')
title('Log returns of Netflix')

%% 0. Test For outliers (GRUBBS TEST, ASSUMES NORMAL DISTR)

price_outliers                      = is_outlier(p); % returns an array of 0's and 1's
return_outliers                     = is_outlier(r); % if 1: that value is grubbs outlier outlier
barndorff_nielsen_price_outliers    = is_barndorff_nielsen_outlier(p); %find outliers as described by Barndorff-nielsen

%count outliers
count_p_outliers                    = 0; % initiate counter
count_r_outliers                    = 0; % initiate counter
count_barndorff_nielsen_p_outliers  = 0; %initiate counter

for i = 1 : length(price_outliers)
    if price_outliers(i) == 1;
        count_p_outliers = count_p_outliers + 1;
    end

    if barndorff_nielsen_price_outliers(i) == 1;
        count_barndorff_nielsen_p_outliers  = count_barndorff_nielsen_p_outliers + 1;
    end
end

for i = 1 : length(return_outliers) % extra loop due to length difference
    if return_outliers(i) == 1;
        count_r_outliers = count_r_outliers + 1;
    end
end

%% 0.1 FIND Realised volatility

date_check      = dates(1); % initialize at first date of series
number_of_days  = size(unique(dates),1); % Find number of different days in sample
RV              = zeros([number_of_days,1]); %initialize array voor Realized Volatility
day_counter     = 1; % initialize day counter

for i = 1 : length(r_adjusted)
    if date_check == dates(i)
        RV(day_counter) = RV(day_counter) + r_adjusted(i)^2; 
    else 
        day_counter     = day_counter + 1;
        RV(day_counter) = r_adjusted(i)^2;
        date_check      = dates(i);
    end      
end   

%% Plot RV and RK

figure(2)
plot(RV)
hold on
plot(realized_kernel, 'r')
axis tight
ylim([0 0.025])

%% 0.2 find daily returns

r_daily_open_to_close   = find_r_open_to_close(r_adjusted, dates); 
r_daily_close_to_close  = find_r_close_to_close(p, dates); 

%% 1. Setup

    x          = (r_daily_open_to_close - mean(r_daily_open_to_close));
    x_training = x(1:1500); % use first 1500 obs for training, last 714 for forecasting

                            %%
%parameters for GARCH
omega_ini = 0.1;
alpha_ini = 0.2;
beta_ini = 0.8;
theta_ini1 = [omega_ini,alpha_ini,beta_ini];
lb1=[0.0001,0,0];    % lower bound for theta
ub1=[10,1,1];   % upper bound for theta

%Parameters for Garch with Leverage
omega=0.1;
alpha=0.05;
beta = 0.9;
delta  = -1;
lambda = 15;
rho = 1;
theta_ini2 = [omega, alpha, beta, delta, lambda, rho];
lb2=[0.0001,0,0, -10, 2,-10];    % lower bound for theta
ub2=[10,1,1, 10, 30, 10];   % upper bound for theta

%Estimate parameters
[par_G, par_RG] = estimate_parameters(x_training, theta_ini1, lb1, ub1, theta_ini2, lb2, ub2);

display('parameter estimates:')
display('omega, alpha, beta, loglikelihood/1000, exitflag')
par_G
display('omega, alpha, beta, delta, lambda, rho, loglikelihood/1000, exitflag')
par_RG
%exitflag must be greater than 0.

%%

GARCH_forecast_RK = forecast_GARCH(par_G, x(1501:2014), realized_kernel(1501:2014));
GARCH_FMSE_RK     = find_FMSE(GARCH_forecast_RK, realized_kernel);
GARCH_FMAE_RK     = find_FMAE(GARCH_forecast_RK, realized_kernel);

Robust_GARCH_forecast_RK    = forecast_ROBUST_GARCH(par_RG, x(1501:2014), realized_kernel(1501:2014));
Robust_GARCH_FMSE_RK        = find_FMSE(Robust_GARCH_forecast_RK, realized_kernel);
Robust_GARCH_FMAE_RK        = find_FMAE(Robust_GARCH_forecast_RK, realized_kernel);

GARCH_forecast_RV = forecast_GARCH(par_G, x(1501:2014), RV(1501:2014));
GARCH_FMSE_RV     = find_FMSE(GARCH_forecast_RV, RV);
GARCH_FMAE_RV     = find_FMAE(GARCH_forecast_RV, RV);

Robust_GARCH_forecast_RV    = forecast_ROBUST_GARCH(par_RG, x(1501:2014), RV(1501:2014));
Robust_GARCH_FMSE_RV        = find_FMSE(Robust_GARCH_forecast_RV, RV);
Robust_GARCH_FMAE_RV        = find_FMAE(Robust_GARCH_forecast_RV, RV);

%% plot 

figure()
subplot(2,2,1);
plot(realized_kernel(1501:2014), 'k')
hold on
plot(GARCH_forecast_RK, 'r')
axis tight
title('GARCH RK forecast');
legend('Realized volatility','Forecast')

subplot(2,2,2);
plot(realized_kernel(1501:2014), 'k')
hold on
plot(Robust_GARCH_forecast_RK, 'r')
axis tight
title('Robust GARCH RK forecast');
legend('Realized kernel','Forecast')

subplot(2,2,3);
plot(RV(1501:2014), 'k')
hold on
plot(GARCH_forecast_RV, 'r')
axis tight
title('GARCH RV forecast');
legend('Realized volatility','Forecast')
ylim([0 0.025])

subplot(2,2,4);
plot(RV(1501:2014), 'k')
hold on
plot(Robust_GARCH_forecast_RV, 'r')
axis tight
title('Robust GARCH RV forecast');
legend('Realized volatility','Forecast')
ylim([0 0.025])

%% 3. Filter volatilities
% [sigG, sigRG] = filter_volatilities(x,par_G,par_RG);
% 
% figure()
% plot(realized_kernel,'k')
% hold on
% plot(sigG(1:end-1), 'r')
% hold on
% plot(sigRG(1:end-1), 'r')
% title('Filtered volatility');
% xlim([0 T])
% xticks(125:250:1875)
% xticklabels({'2007','2008','2009','2010','2011','2012','2013','2014'}) 
% legend('Realized kernel','GARCH filter','Robust-GARCH filter')
