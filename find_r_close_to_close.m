function [av]=is_outlier(P, dates)
    number_of_days  = size(unique(dates),1);
    day_counter     = 1; % initialize day counter
    date_check      = dates(1); % initialize at first date of series
    av              = zeros([number_of_days,1]);
    starting_price  = P(1); 
    
    for i = 1 : length(P) - 1 
        if date_check ~= dates(i + 1)      
            av(day_counter) = P(i) - starting_price;  
            starting_price  = P(i); 
            day_counter     = day_counter + 1;
            date_check      = dates(i+1);
        end      
    end
    
    av(day_counter) = P(end) - starting_price; % add difference final day
    
    av; 
end