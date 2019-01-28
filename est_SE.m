function [SE0] = est_SE(x,theta_hat,robust)
T=length(x);

%Produce score time series (log lik derivatives)
if(robust)
    for t=2:T
        jac(t,:) = jacobianest(@(theta) llik_fun_GARCH_Leverage_Effect(x(t-1:t),theta), theta_hat);
    end
else
    for t=2:T
        jac(t,:) = jacobianest(@(theta) llik_fun_GARCH(x(t-1:t),theta), theta_hat);
    end
end

%Calculate Sigma Matrix under assumption of mds scores
Sigma=cov(jac)*(T-1);
if(robust)
    Omega0=inv(-(T-1)*hessian(@(theta) llik_fun_GARCH_Leverage_Effect(x,theta), theta_hat));
    
else
    Omega0=inv(-(T-1)*hessian(@(theta) llik_fun_GARCH(x,theta), theta_hat));
    
end

%Calculate and display SE without assumption of correct specification
% display('SE calculated without assumption of correct specification')
SE0 = sqrt(diag((Omega0)*Sigma*(Omega0')));
SE0 = SE0';
end