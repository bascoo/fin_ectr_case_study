clear all
clc
load('2007c')
% table           = readtable('2007c.csv'); % Only one day now
% all_dates       = table2array(table(:,2));
% all_times       = table2array(table(:,3));
% all_prices      = table2array(table(:,4));
% clear table % remove burden on workspace

%%

number_of_days  = length(unique(all_dates));
% Realized_kernel = array(number_of_days; % Initiate kernel:  TO DO array length #days
day_end_index = 0; % previous day ended at index 0 

    %% each day: 
for d = 1 : number_of_days
    
    day_start_index = day_end_index + 1; 
    date_check      = all_dates(day_start_index); 
    
    day_end_index = day_start_index;
    while all_dates(day_end_index+1) == date_check && day_end_index + 2 <= length(all_dates) 
        day_end_index = day_end_index + 1;
    end
    
    if day_end_index + 2 > length(all_dates)
        day_end_index = day_end_index + 1; 
    end    
    
    prices      = all_prices(day_start_index:day_end_index);
    log_prices  = log(prices); 
    times       = all_times(day_start_index:day_end_index);

    % FIND BANDWIdTH
    c_star  = 3.5134;
    n       = length(unique(times));    
    xi_2    = find_xi_2(log_prices,times, n); 

    bandwidth   = c_star * xi_2^(2/5) * n^(3/5);

    p_cleaned   = zeros([n,1]); 
    unique_times= unique(times); 

    %remove multiple trades per second and replace by median
    for i = 1 : n 
       indices = find(unique_times(i)  == times);  
       p_cleaned(i) = median(log_prices(indices(1):indices(end)));    
    end    

    X_0         = (p_cleaned(1) + p_cleaned(2)) / 2;
    X_n         = (p_cleaned(end) + p_cleaned(end-1)) / 2; 
    X           = [X_0; p_cleaned; X_n];
    returns     = diff(X); 

    for h = round(-bandwidth) : round(bandwidth)
       gamma_h = 0;  % initiate variable every loop
       for j = abs(h) + 1 : n  
            gamma_h      = gamma_h + returns(j)*returns(j-abs(h));
       end 

       kernel_input = h / (bandwidth+1);
       kernel_output = Parzen_kernel(kernel_input); 

       Realized_kernel(d) = Realized_kernel(d) + (kernel_output * gamma_h);
       %TODO CHANGE TO PER DAY
    end    
end
