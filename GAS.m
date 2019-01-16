clc
clear all
close all

tic

%% Input choices
% #### Distribution
GAUSS = 0; % Gaussian
STUD_T = 1; % Student-t
% ##### Link function
SIGMA = 2; 
LOG_SIGMA = 3;
% ##### Scaling of score
INV_FISHER = 4; %Inverse fisher
INV_SQRT_FISHER = 5; % Inverse sqrt fisher
% ##### Standard errors
HESS = 6;
SAND = 7;
%% load data
load_data = readtable('netflix_resampled_5minutes.csv');
vY = table2array(load_data(:,2))';

%% Input choices
iDistr = GAUSS; % Gaussian distribution
iLinkfunc = LOG_SIGMA; % Link function Log Sigma:  f_t =log(sigma^2_t) 
iScaling = INV_FISHER; % Inverse fisher scaling matrix

% Order of GAS(p,q)
iP = 1;
iQ = 1;
% Standard errors: Hessian
iStdErr = HESS;

%% Starting values
dOmega = 0;
vA = 0.10; 
vB = 0.89;
dMu = 0;
dDf = 5; % only relevant if distr = student-t

%% Work
cT = size(vY,2);
vinput = [iDistr; iLinkfunc; iScaling; iP; iQ; iStdErr];
vp0 = [dOmega; vA; vB; dMu; dDf];
[vp0, aparnames] = StartingValues(vinput, vp0);
options = optimset('TolX', 0.0001, 'Display', 'iter', 'Maxiter', 5000, 'MaxFunEvals', 5000, 'LargeScale', 'off', 'HessUpdate', 'bfgs');
objfun = @(vp)(-LogLikelihoodGasVolaUniv(vp, vinput, vY));
[vp_mle, dloglik] = fminunc(objfun, vp0, options);
fprintf ('Log Likelihood value = %g \r', -dloglik*cT)
[vpplot, vse] = StandardErrors(objfun, vp_mle, cT, vinput, vY);
horzcat(aparnames, num2cell(horzcat(vpplot, vse)))
PlotSeries(vp_mle, vinput, vY, cT);
toc






