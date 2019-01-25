clear all
clc
format compact

%% Load Data
%get the values in the Excel using xlsread.
table           = readtable('netflix_resampled_5minutes.csv');

load('Daily_realized_kernel.mat');  % load realized kernel
%load('datelist_all_trading_days.mat'); % stores 'Full_date_list'

Realized_kernel = All_rk;           % Struct is saved as all_rk, store as Realized_kernel
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
plot(Realized_kernel, 'r')
axis tight
ylim([0 0.025])

%% 0.2 find daily returns

r_daily_open_to_close   = find_r_open_to_close(r_adjusted, dates); 
r_daily_close_to_close  = find_r_close_to_close(p, dates); 

%% 1. Setup

    x = (r_daily_open_to_close - mean(r_daily_open_to_close))*100;
    %n = 500; %Look at last n variables
    %x = x(end-(n-1):end);
%     percntiles = prctile(x,[5 95]); %5th and 95th percentile
%     outlierIndex = x < percntiles(1) | x > percntiles(2);
%     %remove outlier values
%     x(outlierIndex) = [];
    T = length(x); % sample size


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
[par_G, par_RG] = estimate_parameters(x, theta_ini1, lb1, ub1, theta_ini2, lb2, ub2);

display('parameter estimates:')
display('omega, alpha, beta, loglikelihood/1000, exitflag')
par_G
display('omega, alpha, beta, delta, lambda, rho, loglikelihood/1000, exitflag')
par_RG
%exitflag must be greater than 0.
%% 3. Filter volatilities
[sigG, sigRG] = filter_volatilities(x,par_G,par_RG);
y = linspace(0,T,T);
% y = (dates);

figure()
plot(y,x,'k')
hold on
plot(y,sigG(1:end-1), 'r')
hold on
plot(y,sigRG(1:end-1), 'b')
title('Filtered volatility');
legend('Stock returns','GARCH filter','Robust-GARCH filter')

%% 2. Initialization options
% 
% options = optimset('Display','iter',... %display iterations
%     'TolFun',1e-9,... % function value convergence criteria
%     'TolX',1e-9,... % argument convergence criteria
%     'MaxIter',500); % maximum number of iterations
% 
% %% 3. Initialize vars
% 
% omega_ini   = 0.1;
% alpha_ini   = 0.05;
% beta_ini    = 0.90;
% theta_ini   = [omega_ini, alpha_ini, beta_ini];
% 
% lb = [-1, 0, 0];
% ub = [10, 10, 1];
% 
% [theta_hat_normal_GARCH,llik_val_normal_GARCH,exitflag_normal_GARCH,~,~,~, normal_GARCH_hessian]=...
%     fmincon(@(theta) - llik_fun_GARCH(x,theta),theta_ini,[],[],[],[],lb,ub,[],options);
% 
% %% 4. Display output
% 
%     display('parameter estimates:')
%     theta_hat_normal_GARCH
% 
%     display('log likelihood value:')
%     -llik_val_normal_GARCH*(length(x)-1)
% 
%     display('exit flag:')
%     exitflag_normal_GARCH   %if exitflag>0: convergence ok
%                             %if exitflag<=0: convergence failed

% %% 5. Find filtered volatility
% 
%     omega_hat   = theta_hat_normal_GARCH(1);
%     alpha_hat   = theta_hat_normal_GARCH(2);
%     beta_hat    = theta_hat_normal_GARCH(3);
% 
%     filtered_sigma      = zeros([T,1]);
%     filtered_sigma(1)   = omega_hat / (1 - alpha_hat - beta_hat);
% 
%     for i = 2 : T
%        filtered_sigma(i) = omega_hat + alpha_hat * x(i-1)^2 + beta_hat * filtered_sigma(i-1);
%     end
% 
% %% 6. Plot
% 
%     figure(3)
% 
%     plot(filtered_sigma, 'r')

%% 3. Estimate values using ML

% %% 2. Parameter Values
%
%       omega=0.1;
%       alpha=0.1;
%       beta=0.98;
%
% %% 3. Define Vectors
%
%       sigma=zeros(1,T);
%
% %% 4. Filter Volatility
%
%       sigma(1)=var(x); %initialize volatility at unconditional variance
%
%       for t=1:T
%
%           sigma(t+1) = omega + alpha*x(t)^2 + beta*sigma(t);
%
%       end
%
% %% 5. Calculate Log Likelihood Values
%
%       %construct sequence of log lik contributions
%       l = -(1/2)*log(2*pi) - (1/2)*log(sigma(1:T)) - (1/2)*(x').^2./sigma(1:T);
%
%       %calculate average log likelihood
%       L = mean(l);
%
%
% %% 6. Plots
% figure()
% subplot(2,1,1)
% plot(x,'k')      % plot data
% hold on
% plot(sigma,'r')    %plot filtered volatility
% xlim([1 T])
%
% subplot(2,1,2)
% plot(l)             %plot individual loglikelihood contributions
% line([1 T], [L L])  %draw line of average log likelihood
% xlim([1 T])


% %% 1. Setup ML
%
% x = y*1000;
%
%
%
% x = x(1:5000);
% %     %Look at last i variables
% %     i = 500
% %     x = x(end-i:end);
%
% %% 2. Optimization Options
%
%       options = optimset('Display','iter',... %display iterations
%                          'TolFun',1e-12,... % function value convergence criteria
%                          'TolX',1e-12,... % argument convergence criteria
%                          'MaxIter',100); % maximum number of iterations
%
% %% 4. Initial Parameter Values
%
%       omega_ini = 0.1;% initial value for omega
%       alpha_ini = 0.2;  % initial value for alpha
%       beta_ini = 0.99;   % initial value for beta
%
%       theta_ini = [omega_ini,alpha_ini,beta_ini];
%
%
% %% 5. Parameter Space Bounds
%
%       lb=[0.0001,0,0];    % lower bound for theta
%       ub=[1000,100,1];   % upper bound for theta
%
%
% %% 6. Optimize Log Likelihood Criterion
%
%       % fmincon input:
%       % (1) negative log likelihood function: - llik_fun_AR1()
%       % (2) initial parameter: theta_ini
%       % (3) parameter space bounds: lb & ub
%       % (4) optimization setup: options
%       %  Note: a number of parameter restriction are left empty with []
%
%       % fmincon output:
%       % (1) parameter estimates: theta_hat
%       % (2) negative average log likelihood value at theta_hat: ls_val
%       % (3) exit flag indicating (no) convergence: exitflag
%
%       [theta_hat,llik_val,exitflag]=...
%           fmincon(@(theta) - llik_fun_GARCH(x,theta),theta_ini,[],[],[],[],lb,ub,[],options);
%
%
%
% %% 7. Print Output
%
% display('parameter estimates:')
% theta_hat
%
% display('log likelihood value:')
% -llik_val*(length(x)-1)
%
% display('exit flag:')
% exitflag %if exitflag>0: convergence ok
%          %if exitflag<=0: convergence failed
