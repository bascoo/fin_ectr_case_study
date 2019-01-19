%%detect entries in which price deviates by more than 
%%10 mean absolute deviations from rolling centered median 
%%(median of 25 observations before and after) 

% NOTE: THIS METHOD NEGLECTS THE FIRST AND FINAL 25 OBSERVATIONS 

function [av]=is_barndorff_nielsen_outlier(FF)
    av = zeros([length(FF),1]); 
    for i = 26 : (length(FF) - 25) % Do first 25 observations
        A                       = FF(i-25:i+25); 
        med                     = median(A); 
        mean_absolute_deviation = mad(A); 
        difference              = abs(FF(i)-med); 
        if difference > (10 * mean_absolute_deviation); 
            av(i) = 1;
        end    
    end     
    av;
 end