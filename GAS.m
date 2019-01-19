% GAS
%% Load data
x = readtable('netflix_resampled_5minutes.csv');

%% 
tableprice = table2array(x(:,2));
tabledates = table2array(x(:,1));
%%
figure(1);clf
plot(tabledates,tableprice)