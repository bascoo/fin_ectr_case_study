clear all 
clc

%get the values in the Excel using xlsread.
table           = readtable('netflix_resampled_5minutes.csv');
datetime        = table2array(table(:,1));
netflixPrice    = table2array(table(:,2)); 

%%

p               = log(netflixPrice); % log price
r               = diff(p);           % log return
mean_r          = mean(r); 
y               = r - mean_r;

plot(p, 'b')
hold on
plot(r, 'r')

%% 0. Test For outliers (GRUBBS TEST, ASSUMES NORMAL DISTR) 

price_outliers = is_outlier(p); % returns an array of 0's and 1's
return_outliers = is_outlier(r); % if 1: that value is an outlier

%count outliers
count_p_outliers = 0; % initiate counter
count_r_outliers = 0; % initiate counter

for i = 1 : length(price_outliers)
    if price_outliers(i) == 1;
        count_p_outliers = count_p_outliers + 1; 
    end
end

for i = 1 : length(return_outliers) % extra loop due to length difference
    if return_outliers(i) == 1;
        count_r_outliers = count_r_outliers + 1; 
    end
end

%% 1. Setup

    x = y*1000;
    n = 500; %Look at last n variables
    x = x(end-(n-1):end);
%     percntiles = prctile(x,[5 95]); %5th and 95th percentile
%     outlierIndex = x < percntiles(1) | x > percntiles(2);
%     %remove outlier values
%     x(outlierIndex) = [];
    T = length(x); % sample size

%% 2. Initializa options 

    options = optimset('Display','iter',... %display iterations
                         'TolFun',1e-9,... % function value convergence criteria 
                         'TolX',1e-9,... % argument convergence criteria
                         'MaxIter',500); % maximum number of iterations   
    
%% 3. Initialize vars
    
    omega_ini   = 0.1;
    alpha_ini   = 0.1;
    beta_ini    = 0.98; 
    theta_ini   = [omega_ini, alpha_ini, beta_ini];
    
    lb = [-1, 0, 0]; 
    ub = [10, 10, 1];
    
    [theta_hat_normal_GARCH,llik_val_normal_GARCH,exitflag_normal_GARCH,~,~,~, normal_GARCH_hessian]=...
          fmincon(@(theta) - llik_fun_GARCH(x,theta),theta_ini,[],[],[],[],lb,ub,[],options);

    % TODO: Find std errors  
      
%% 4. Display output

    display('parameter estimates:')
    theta_hat_normal_GARCH

    display('log likelihood value:')
    -llik_val_normal_GARCH*(length(x)-1)

    display('exit flag:')
    exitflag_normal_GARCH   %if exitflag>0: convergence ok
                            %if exitflag<=0: convergence failed
                            
%% 5. Find filtered volatility

    omega_hat   = theta_hat_normal_GARCH(1);
    alpha_hat   = theta_hat_normal_GARCH(2);
    beta_hat    = theta_hat_normal_GARCH(3);
    
    epsilon             = normrnd(0,1,[T,1]); 
    filtered_sigma      = zeros([T,1]);
    filtered_sigma(1)   = omega_hat / (1 - alpha_hat - beta_hat);
    
    for i = 2 : T
       filtered_sigma(i) = omega_hat + alpha_hat * x(i-1)^2 + beta_hat * filtered_sigma(i-1);
    end    

    y_hat = sqrt(filtered_sigma) .* epsilon;
%% 6. Plot 

    figure(3) 

    plot(x, 'k')
    hold on
    plot(y_hat, 'r')

%% 3. Estimate values using ML     
    
% %% 2. Parameter Values
% 
%       omega=0.1;
%       alpha=0.1;
%       beta=0.98;
%       
% %% 3. Define Vectors
% 
%       sigma=zeros(1,T); 
%       
% %% 4. Filter Volatility
% 
%       sigma(1)=var(x); %initialize volatility at unconditional variance
% 
%       for t=1:T
%           
%           sigma(t+1) = omega + alpha*x(t)^2 + beta*sigma(t);
%                   
%       end
%       
% %% 5. Calculate Log Likelihood Values
% 
%       %construct sequence of log lik contributions
%       l = -(1/2)*log(2*pi) - (1/2)*log(sigma(1:T)) - (1/2)*(x').^2./sigma(1:T); 
%       
%       %calculate average log likelihood
%       L = mean(l);
%       
%      
% %% 6. Plots
% figure()
% subplot(2,1,1)
% plot(x,'k')      % plot data
% hold on
% plot(sigma,'r')    %plot filtered volatility
% xlim([1 T])
% 
% subplot(2,1,2)
% plot(l)             %plot individual loglikelihood contributions
% line([1 T], [L L])  %draw line of average log likelihood
% xlim([1 T])


% %% 1. Setup ML
% 
% x = y*1000;
% 
% 
% 
% x = x(1:5000);
% %     %Look at last i variables
% %     i = 500
% %     x = x(end-i:end);
% 
% %% 2. Optimization Options
% 
%       options = optimset('Display','iter',... %display iterations
%                          'TolFun',1e-12,... % function value convergence criteria 
%                          'TolX',1e-12,... % argument convergence criteria
%                          'MaxIter',100); % maximum number of iterations    
% 
% %% 4. Initial Parameter Values
%       
%       omega_ini = 0.1;% initial value for omega
%       alpha_ini = 0.2;  % initial value for alpha
%       beta_ini = 0.99;   % initial value for beta
%       
%       theta_ini = [omega_ini,alpha_ini,beta_ini];
%       
%       
% %% 5. Parameter Space Bounds
%         
%       lb=[0.0001,0,0];    % lower bound for theta
%       ub=[1000,100,1];   % upper bound for theta
%       
%       
% %% 6. Optimize Log Likelihood Criterion
%       
%       % fmincon input:
%       % (1) negative log likelihood function: - llik_fun_AR1()
%       % (2) initial parameter: theta_ini
%       % (3) parameter space bounds: lb & ub
%       % (4) optimization setup: options
%       %  Note: a number of parameter restriction are left empty with []
% 
%       % fmincon output:
%       % (1) parameter estimates: theta_hat
%       % (2) negative average log likelihood value at theta_hat: ls_val
%       % (3) exit flag indicating (no) convergence: exitflag
%       
%       [theta_hat,llik_val,exitflag]=...
%           fmincon(@(theta) - llik_fun_GARCH(x,theta),theta_ini,[],[],[],[],lb,ub,[],options);
%       
%  
%       
% %% 7. Print Output
% 
% display('parameter estimates:')
% theta_hat
% 
% display('log likelihood value:')
% -llik_val*(length(x)-1)
% 
% display('exit flag:')
% exitflag %if exitflag>0: convergence ok
%          %if exitflag<=0: convergence failed
