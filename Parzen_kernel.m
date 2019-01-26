function [av]=Parzen_kernel(x)
    if 0 <= abs(x) && abs(x) <= 1/2
        av = 1 - 6 * (abs(x))^2 + 6 * (abs(x))^3;
    elseif abs(x) > 1/2 && abs(x) <=1
        av = 2 * ((1-abs(x))^3); 
    else 
        av = 0;
    end
    
    av; 
end