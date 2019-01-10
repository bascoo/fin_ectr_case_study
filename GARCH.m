clear all 
clc

%get the values in the Excel using xlsread.
table           = readtable('netflix_resampled_5minutes.csv');
datetime        = table2array(table(:,1));
netflixPrice    = table2array(table(:,2)); 

%%

p               = log(netflixPrice); % log price
r               = diff(p);           % log return
mean_r          = mean(r); 
y               = r - mean_r;

plot(p, 'b')
hold on
plot(r, 'r')