function  [llik] = llik_fun_GARCH(x,theta)


T=length(x);

omega=theta(1);
alpha=theta(2);
beta=theta(3);

%% Filter Volatility

sig(1)=var(x); %initialize volatility at unconditional variance

for t=1:T
    
    sig(t+1) = omega + alpha*x(t)^2 + beta*sig(t);
    
end

%% Calculate Log Likelihood Values

%construct sequence of log lik contributions
l = -(T/2)*log(2*pi) - (1/2)*log(sig(1:T)) - (1/2)*(x').^2./sig(1:T);

% mean log likelihood
llik =mean(l);