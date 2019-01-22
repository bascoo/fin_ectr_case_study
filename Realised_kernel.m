clear all
clc

%% Load Data
%get the values in the Excel using xlsread.
table           = readtable('Alcoa4May2007.csv'); % Only one day now
table           = table(1:end-1,3:4);

%%

% find number of days
% create vector of length arrays


% for i = 1 : number of days 
%find and store all obs in day


%% each day: 

prices      = table2array(table(:,2));
log_prices  = log(prices); 
times       = table2array(table(:,1)); 

% FIND BANDWIdTH
c_star  = 3.5134;
n       = 0;    % TO DO?  ? ? 
xi_2    = find_xi_2(log_prices,times); 

bandwidth = c_star * xi_2^(2/5) * n^(3/5);

% for h = -BANDWIdTH : BANDWIdTH
% input = h / (bandwith + 1); 
% value = Parzen_kernel(input); 
% gamma_h 
% Realised_kernal(day) = k(input) * gamma_h

