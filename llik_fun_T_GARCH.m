function  [llik] = llik_fun_GARCH(y,theta)
     
    T = length(y); 
    
    omega   = theta(1);
    alpha   = theta(2);
    beta    = theta(3);
    v       = theta(4); % Degrees of freedom
    
    sigma_sqrt      = zeros([T,1]); 
    sigma_sqrt(1)   = var(y); %omega / (1 - alpha - beta); 
    
    for t = 2 : T 
        sigma_sqrt(t) = omega + alpha * y(t-1)^2 + beta * sigma_sqrt(t-1); 
    end
    
    l = t * log(gamma((v+1)/2)) - t * log(gamma(v/2)) - 0.5 * log((v-2)*pi*sigma_sqrt) ...
        - ((v+1)/2) * log(1 +( y.^2 ./ ((v-2)*sigma_sqrt)));
    
    llik = mean(l); 
end