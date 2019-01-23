function [av]=find_xi_2(p, t, n)

    %Find IV_hat
    starttime   = duration(9,30,0);
    endtime     = duration(16,0,0); 
    allseconds  = starttime: duration(0,0,1): endtime; 
    
    price_per_second    = zeros([length(allseconds),1]); 
    price_per_second(1) = p(1);  
    
    % match a price to every second
    for i = 2 : length(allseconds) 
        indices = find(t == starttime + duration(0,0,i)); % returns the indices of the times trade occurs at this moment
        
        if isempty(indices)
            price_per_second(i) = price_per_second(i-1); 
        elseif  size(indices,1) > 1
            median(p(indices(1):indices(end)));
        else 
            price_per_second(i) = p(indices);
        end    
    end    
    
    RV = zeros([1200,1]); % initiate array of 1200 RV values
    
    % loop 1200 times for each second
    for i = 1 : 1200 
        for j = i : 1200 : length(allseconds) - 1200 % remove 1200
            RV(i) = RV(i) + ((price_per_second(j+1200) - price_per_second(j))^2);
        end    
    end    
    
    IV_hat = mean(RV); % IV_hat = RV_sparse = the average of all RVs
    
    % find omega squared hat
    q = round(n / 195); 
    
    omega_squared_hat = zeros([q,1]);
    RV_dense          = zeros([q,1]);
    non_zero_returns  = zeros([q,1]);
    
    for i = 1 : q
        for j = i : q : (length(p)-q)
            RV_dense(i)         = RV_dense(i) + ((p(j+q)-p(j))^2);   
            if p(j+q)-p(j) ~= 0 
                non_zero_returns(i) = non_zero_returns(i) + 1;
            end    
        end 
        
        omega_squared_hat(i) = RV_dense(i)/ (2*non_zero_returns(i)); 
    end    
    
    avg_omega_squared_hat = mean(omega_squared_hat); % TODO

    % return xi_squared_hat
    av = avg_omega_squared_hat / IV_hat;
    av; 
end