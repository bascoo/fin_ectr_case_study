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
% hold on
% plot(y, 'k')

%% 1. Setup
      
    x = y*1000;
    %Look at last i variables
    i = 500;
    x = x(end-i:end);
%     percntiles = prctile(x,[5 95]); %5th and 95th percentile
%     outlierIndex = x < percntiles(1) | x > percntiles(2);
%     %remove outlier values
%     x(outlierIndex) = [];

    T=length(x); % sample size

%% 2. Parameter Values

      omega=0.1;
      alpha=0.1;
      beta=0.98;
      
%% 3. Define Vectors

      sig=zeros(1,T); 
      
%% 4. Filter Volatility

      sig(1)=var(x); %initialize volatility at unconditional variance

      for t=1:T
          
          sig(t+1) = omega + alpha*x(t)^2 + beta*sig(t);
                  
      end
      
%% 5. Calculate Log Likelihood Values

      %construct sequence of log lik contributions
      l = -(1/2)*log(2*pi) - (1/2)*log(sig(1:T)) - (1/2)*(x').^2./sig(1:T); 
      
      %calculate average log likelihood
      L = mean(l);
      
     
%% 6. Plots
figure()
subplot(2,1,1)
plot(x,'k')      % plot data
hold on
plot(sig,'r')    %plot filtered volatility
xlim([1 T])

subplot(2,1,2)
plot(l)             %plot individual loglikelihood contributions
line([1 T], [L L])  %draw line of average log likelihood
xlim([1 T])


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
