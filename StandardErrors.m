function [vpplot, vse] = StandardErrors(objfun, vp, cT, vinput, vy)
ilinkfunction = vinput(2);
ip = vinput(4);
iq = vinput(5);
istderr = vinput(6);
dpar = length(vp);
mhessian = hessian(objfun, vp);
minvhess = mhessian\eye(dpar);
vse = sqrt(diag(minvhess)/cT);
vpplot = vp;
if ilinkfunction == 2  %SIGMA
    vse(1) = vse(1)*exp(vp(1)); % Delta method
    vpplot(1) = exp(vp(1));
end 
if(istderr == 6)   %HESS
    return 
elseif(istderr == 7) %SAND
    dh = 1e-06;
	mcontr_grad = zeros(cT-max(ip, iq), dpar);
    [dloglik, vf, vscore, vscaledsc, vfunc] = LogLikelihoodGasVolaUniv(vp, vinput, vy);
	vllik = vfunc;
    for i = 1:dpar    
		vptemp = vp;
		vptemp(i) = vptemp(i) + dh;
		[dloglik, vf, vscore, vscaledsc, vfunc] = LogLikelihoodGasVolaUniv(vptemp, vinput, vy);
		vllik_h = vfunc;
		mcontr_grad(1:end,i) = (vllik_h-vllik)./dh; % Matrix of contributions to the gradient
    end
	minnerp = (mcontr_grad'*mcontr_grad)/cT;
	mvar = minvhess*minnerp*minvhess;
    vse = sqrt(diag(mvar)/cT);
    return
else
fprintf ('Choose HESS or SAND to obtain standard errors')        
end