function[DM_FMSE, DM_FMAE] = find_Diebold_Mariano_test_stat(x1, x2, observations)
%This function returns the diebold-mariano test stat for both the FMAE as
%well as the FMSE with the 2 tested forecasts as input. The third input
%parameter is the vector of actual observations. 
    n = length(x1); 
    observations = observations(end-n+1:end); 
    
    errors_x1 = x1 - observations;
    errors_x2 = x2 - observations;
    
    d_FMSE = errors_x1.^2 - errors_x2.^2;
    d_FMAE = abs(errors_x1) - abs(errors_x2);
    
    d_bar_FMSE = sum(d_FMSE)/n; 
    d_bar_FMAE = sum(d_FMAE)/n; 
    
    DM_FMSE = sqrt(n) * (d_bar_FMSE/std(d_FMSE));
    DM_FMAE = sqrt(n) * (d_bar_FMAE/std(d_FMAE));
    
    DM_FMSE;
    DM_FMAE;
end
