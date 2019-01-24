clc
clear all
close all

tic % start counter

%% load data
table           = readtable('netflix_resampled_5minutes.csv');
datetime        = char(table2array(table(:,1)));
dates           = datetime(:,1:10);
times           = datetime(:,11:19);
dates           = char_to_string(dates);
times           = char_to_string(times);
netflixPrice    = table2array(table(:,2));
p               = log(netflixPrice); % log price
r               = diff(p);           % log return 
r_adjusted      = [0; r];   % first return = 0 so array sizes match

%% Daily returns
r_daily_open_to_close   = find_r_open_to_close(r_adjusted, dates); 
r_daily_close_to_close  = find_r_close_to_close(p, dates); 

%% Input choices
% #### Distribution
GAUSS           = 0; % Gaussian
STUD_T          = 1; % Student-t
SKWD_T          = 99; % Skewed-t

% ##### Link function
SIGMA           = 2; 
LOG_SIGMA       = 3;

% ##### Scaling of score
INV_FISHER      = 4; %Inverse fisher
INV_SQRT_FISHER = 5; % Inverse sqrt fisher

% ##### Standard error type
HESS            = 6; % Hessian
SAND            = 7; % Sandwich estimator

%% input data for model daily
% 1 = open/close, 2 = close/close
DailyData = 1;

if DailyData == 1
    vY = r_daily_open_to_close';
elseif DailyData == 2
    vY = r_daily_close_to_close';
else
    error('Specify daily data type');
end


%% Input choices
iDistr      = STUD_T; % Gaussian distribution
iLinkfunc   = LOG_SIGMA; % Link function Log Sigma:  f_t =log(sigma^2_t) 
iScaling    = INV_FISHER; % Inverse fisher scaling matrix

% Order of GAS(p,q)
iP = 1;
iQ = 1;
% Standard errors: Hessian
iStdErr     = HESS;

%% Starting values
dOmega  = 0;
vA      = 0.10; 
vB      = 0.89;
dMu     = 0;
dDf     = 5; % degrees of freedom, only relevant if distr = student-t

%% Work
cT                  = size(vY,2);
vinput              = [iDistr; iLinkfunc; iScaling; iP; iQ; iStdErr];
vp0                 = [dOmega; vA; vB; dMu; dDf];
[vp0, aparnames]    = StartingValues(vinput, vp0);
options             = optimset('TolX', 0.0001, 'Display', 'iter', 'Maxiter', 5000, 'MaxFunEvals', 5000, 'LargeScale', 'off', 'HessUpdate', 'bfgs');
objfun              = @(vp)(-LogLikelihoodGasVolaUniv(vp, vinput, vY));
[vp_mle, dloglik]   = fminunc(objfun, vp0, options);

fprintf ('Log Likelihood value = %g \r', -dloglik*cT)

[vpplot, vse]       = StandardErrors(objfun, vp_mle, cT, vinput, vY);
horzcat(aparnames, num2cell(horzcat(vpplot, vse)))
[ts1, ts2, ts3]     = PlotSeries(vp_mle, vinput, vY, cT);

toc % end counter


