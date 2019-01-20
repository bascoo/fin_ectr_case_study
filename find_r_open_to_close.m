function [av]=is_outlier(R, dates)
    number_of_days  = size(unique(dates),1);

    day_counter     = 1; % initialize day counter
    date_check      = dates(1); % initialize at first date of series
    av              = zeros([number_of_days,1]);
   
    for i = 1 : length(R)
        if date_check == dates(i)
            av(day_counter) = av(day_counter) + R(i);  
        else 
            day_counter     = day_counter + 1; 
            av(day_counter) = R(i);  
            date_check      = dates(i);
        end      
    end   
    
    av; 
end