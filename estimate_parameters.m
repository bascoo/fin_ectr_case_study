function  [parameters_Garch, parameters_Robust_Garch, parameters_T_Garch] ...
    = estimate_parameters(x,theta_ini1, lb1, ub1, theta_ini2, lb2, ub2, theta_ini3, lb3, ub3)


options = optimset('TolFun',1e-12,... % function value convergence criteria
    'TolX',1e-12,... % argument convergence criteria
    'MaxIter',100); % maximum number of iterations

options2 = optimset('TolFun',1e-12,... % function value convergence criteria
    'TolX',1e-12,... % argument convergence criteria
    'MaxIter',500); % maximum number of iterations

options3 = optimset('TolFun',1e-12,... % function value convergence criteria
    'TolX',1e-12,... % argument convergence criteria
    'MaxIter',500); % maximum number of iterations


[theta_hat,llik_val,exitflag]=...
    fmincon(@(theta) - llik_fun_GARCH(x,theta),theta_ini1,[],[],[],[],lb1,ub1,[],options);

[theta_hat2,llik_val2,exitflag2]=...
    fmincon(@(theta2) - llik_fun_GARCH_Leverage_Effect(x,theta2),theta_ini2,[],[],[],[],lb2,ub2,[],options2);

[theta_hat3,llik_val3,exitflag3]=...
    fmincon(@(theta3) - llik_fun_T_GARCH(x,theta3),theta_ini3,[],[],[],[],lb3,ub3,[],options3);

logLik                  = -llik_val*(length(x-1));
parameters_Garch        = [theta_hat, logLik/1000, exitflag]; %logLik/1000 to make values show
logLik2                 = -llik_val2*(length(x-1));
parameters_Robust_Garch = [theta_hat2, logLik2/1000, exitflag2];
logLik3                 = -llik_val3*(length(x-1)); 
parameters_T_Garch      = [theta_hat3, logLik3/1000, exitflag3];

% se_GARCH = zeros(3, 3);
% se_RGARCH = zeros(3, 6);

% se_GARCH = estimate_SE_parameters(x, parameters_Garch(1:3), 0);
% se_RGARCH = estimate_SE_parameters(x,parameters_Robust_Garch(1:6), 1);
% se_GARCH
% se_RGARCH

% se_GARCH = zeros(5, 3);
% se_RGARCH = zeros(5, 6);

se_GARCH = est_SE(x, parameters_Garch(1:3), 0);
se_RGARCH = est_SE(x,parameters_Robust_Garch(1:6), 1);
se_TGARCH = est_SE(x,parameters_T_Garch, 2);

se_GARCH
se_RGARCH
se_TGARCH
end