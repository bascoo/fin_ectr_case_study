function [dloglik, vf, vscore, vscaledsc, vfunc] = LogLikelihoodGasVolaUniv(vp, vinput, vy)
idistribution = vinput(1);
ilinkfunction = vinput(2);
iscalingchoice = vinput(3);
ip = vinput(4);
iq = vinput(5);
istderr = vinput(6);
iDP = vinput(7);
cT = size(vy, 2);
dloglik = 0;
vf = zeros(1, cT); 
vscore = zeros(1, cT); 
vscaledsc = zeros(1, cT);
[domega, vA, vB, dmu, ddf] = TransformPar(vp, ilinkfunction, idistribution, ip, iq);

imaxpq = max(ip, iq);
vf(1:imaxpq) = domega/(1 - sum(vB)); % Unconditional mean of factor f
[vf, vscore, vscaledsc] = Init(vf, vscore, vscaledsc, dmu, imaxpq, ddf, ilinkfunction, vy, idistribution, iscalingchoice); 
vfunc = zeros(cT-imaxpq, 1);
for t = imaxpq+1:cT				
	vf(t) = domega + vscaledsc(t-ip:t-1)*vA + vf(t-iq:t-1)*vB;
    if(ilinkfunction == 2)  %SIGMA
        dsigma2_t = vf(t);
    else
        dsigma2_t = exp(vf(t));
    end
	[dscore, dinvfisher, dllik] = SystemMatrices(vy(t)-dmu, dsigma2_t, ddf, idistribution, ilinkfunction);		
    if(istderr == 7)  %SAND
        vfunc(t-imaxpq) = dllik; 
    end
    vscore(t) = dscore;   
%% stop estimating till datapoint     
    if t < iDP 
	dloglik = dloglik + dllik;
    end
	dscale = Scaling(dinvfisher, iscalingchoice);
	vscaledsc(t) = dscale*dscore;
end
if(idistribution == 0) %GAUSS
    dloglik = double((-log(2*pi)*(cT-imaxpq)/2 + dloglik)/cT);
elseif(idistribution == 1) %STUD_T
    dloglik = double(dloglik/cT);
elseif(idistribution == 99) %SKEWED STUDENT-T
    
end
if(isfinite(dloglik) == 0 || isreal(dloglik) == 0 || sum(vB) > 1)
    dloglik = -100;
end    
end

    
function [domega, vA, vB, dmu, ddf] = TransformPar(vP, ilinkfunction, idistribution, ip, iq)
if ilinkfunction == 2   %SIGMA
    domega = exp(vP(1));
else
    domega = vP(1);
end
vA = flipud(vP(2:ip+1));
vB = flipud(vP(1+ip+1:1+ip+iq));
if idistribution == 0  %GAUSS
	dmu = vP(1+ip+iq+1);
	ddf = 0;	
elseif idistribution == 1	%STUD_T
	dmu = vP(1+ip+iq+1);
	ddf = vP(1+ip+iq+2);
end
end
    

function [vf, vscore, vscaledsc] = Init(vf, vscore, vscaledsc, dmu, imaxpq, ddf, ilinkfunction, vy, idistribution, iscalingchoice)
for p = 1:imaxpq
	if ilinkfunction == 2   %SIGMA
		dsigma2_t = vf(p);
	else
		dsigma2_t = exp(vf(p));
end 
    [dscore, dinvfisher, dllik] = SystemMatrices(vy(p)-dmu, dsigma2_t, ddf, idistribution, ilinkfunction);
    vscore(p) = dscore;
	dscale = Scaling(dinvfisher, iscalingchoice);
	vscaledsc(p) = dscale*dscore;
end
end


function [dscore, dinvfisher, dllik] = SystemMatrices(dy, dsigma2_t, ddf, idistribution, ilinkfunction)
if idistribution == 0     %GAUSS
	dscore = (dy^2-dsigma2_t)/(2*dsigma2_t^2);
	dinvfisher = 2*dsigma2_t^2;
	dllik = -log(dsigma2_t)/2 - dy^2/(2*dsigma2_t);
elseif idistribution == 1    %STUD_T 
	dw = (1 + (dy^2/((ddf-2)*dsigma2_t)))^-1*((ddf+1)/(ddf-2));	
	dscore = dw*dy^2/(2*dsigma2_t^2) - 1/(2*dsigma2_t);
	dinvfisher = (2*dsigma2_t^2*(ddf+3))/ddf; 
	dllik = log(gamma((ddf+1)/2)) - log(gamma(ddf/2)) - log((ddf-2)*pi)/2 - log(dsigma2_t)/2 - ((ddf+1)/2)*log(1+(dy^2/((ddf-2)*dsigma2_t)));
else 
    error('Specify correct distribution type');
end    
if ilinkfunction == 3 %LOG_SIGMA
	dscore = dscore*dsigma2_t; % Apply chain rule
	dinvfisher = dinvfisher/dsigma2_t^2;
end 
end


function dscale = Scaling(dinvfisher, iscalingchoice)
if iscalingchoice == 4   %INV_FISHER
	dscale = dinvfisher;
elseif iscalingchoice == 5 %INV_SQRT_FISHER
	dscale = sqrt(dinvfisher);
else 
	error('Specify correct scaling type');
end
end
