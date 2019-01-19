clear all 
clc

%%this is a test
%%SA test

%% Load data
x = readtable('netflix_resampled_5minutes.csv');

%% 
tableprice = table2array(x(:,2));
tabledates = table2array(x(:,1));
%%
figure(1);clf
plot(tabledates,tableprice)

%% Garch object

md1 = garch(1,1);
EstMd1 = estimate(md1

