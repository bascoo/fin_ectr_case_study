%%grubs test 
function [av]=is_outlier(FF)
    mu      = mean(FF);
    stdev   = std(FF);
    for i = 1 : length(FF)
        G(i) =   abs(FF(i)-mu) / stdev;
    end
    alpha = 0.05; 
    critical_val = tinv((alpha/(2*length(FF))), length(FF)-2);
    rejection_val = ((length(FF)-1)/sqrt(length(FF))) * sqrt(critical_val^2/(length(FF)-2+critical_val^2));
    for i = 1 : length(FF)
        if G(i) > rejection_val
            av(i) = 1;
        else 
            av(i) = 0;
        end
    end    
    max(G)
    rejection_val
    av;
 end