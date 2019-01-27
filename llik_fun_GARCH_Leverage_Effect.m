function  [llik] = llik_fun_GARCH_Leverage_Effect(x,theta)


T=length(x);

%(omega, alpha, beta, delta, lambda, rho)
omega=theta(1);
alpha=theta(2);
beta=theta(3);
delta =theta(4);
lambda = theta(5);
rho = theta(6);

%% Filter Volatility

sig(1)=var(x); %initialize volatility at unconditional variance

for t=1:T
    
    sig(t+1) = omega + alpha *   (x(t)^2 + delta * x(t)) / (1 + (rho / lambda) * x(t)^2)  + beta*sig(t) ;
    
end

%% Calculate Log Likelihood Values

%construct sequence of log lik contributions
%l = -(1/2)*log(2*pi) - (1/2)*log(sig(1:T)) - (1/2)*(x').^2./sig(1:T); 
eps = x'./sqrt(sig(1:T));
l = log(tpdf(eps,lambda)) - (1/2)*log(sig(1:T));

% mean log likelihood
llik = mean(l);