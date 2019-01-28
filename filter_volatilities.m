function  [sigG, sigRG] = filter_volatilities(x,parameters_GARCH,parameters_Robust_Garch)

% Allocate memory for filtered volatillities
T = length(x);
sigG = zeros(T,1);
sigRG = zeros(T,1);

sigG(1) = var(x);
sigRG(1) = var(x);

omegaG= parameters_GARCH(1);
alphaG= parameters_GARCH(2);
betaG = parameters_GARCH(3);

%   Parameters Robust Garch
omegaRG= parameters_Robust_Garch(1);
alphaRG= parameters_Robust_Garch(2);
betaRG = parameters_Robust_Garch(3);
deltaRG  = parameters_Robust_Garch(4);
lambdaRG = parameters_Robust_Garch(5);
rhoRG =  parameters_Robust_Garch(6);

for t = 1:T
    sigG(t+1) = omegaG + alphaG * x(t)^2 + betaG * sigG(t);
    sigRG(t+1) = omegaRG+alphaRG * (x(t)^2 + deltaRG * x(t)) / (1+ (rhoRG / lambdaRG) * x(t)^2)+betaRG*sigRG(t);
end
end