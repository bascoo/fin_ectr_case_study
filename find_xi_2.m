function [av]=find_xi_2(p, t)

    %Find IV_hat
    starttime   = duration(9,30,0);
    endtime     = duration(16,0,0); 
    allseconds  = starttime: duration(0,0,1): endtime; 
    
    price_per_second = zeros([length(allseconds),1]); 
    % koppel een price aan iedere seconde
    
    RV_sparse = zeros([1200,1]); 
    
    % loop 1200 !!! fucking keer en vind de RV op interval van 20 min, pak
    % iedere keer t1 + 1 second
    
    IV_hat = sum(RV_sparse) / 1200; % TO DO RV_sparse 20 min
    
    
    % find omega squared hat
    omega_hat_2 = 0; % TODO

    % return xi_squared_hat
    
    av = omega_hat_2 / IV_hat;
    av; 
end