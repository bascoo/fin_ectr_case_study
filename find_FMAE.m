function [result]=find_FMAE(forecasts, actual_obs)
    % Load forecast (1 to 4 years of obs) 
    % Load full vector of actual obs (RV or Realized kernel) 
    n = length(forecasts); 
    actual_obs = actual_obs(end-n+1: end); 
    
    result = (sum(abs(forecasts-actual_obs)))/n; 
    result;
end