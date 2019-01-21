function mH = hessian(fun, vX0)
% function mH = hessian(fun, vX0)
%
%  Purpose:
%    Calculate the numerical hessian at vX0
%
%  Inputs:
%    fun    name of the multidimensional scalar function
%           (string). This function takes a vector argument of
%           length iP and returns a scalar.
%    vX0    iP x 1 vector, point of interest
%
%  Outputs:
%    mH     iP x iP matrix containing the hessian of fun at vX0. 
%
%  Author:
%    Charles Bos
%
%  Based on code from
%    http://www.matrixlab-examples.com/gradient.html
%  and 
%    maximize.ox (c Jurgen Doornik)
%
 
 % |delta(i)| is relative to |vX0(i)|
delta = vX0 / 1000;             
iP= length(vX0);

df= feval(fun, vX0);
for i = 1 : iP
  if vX0(i) == 0
    % avoids delta(i) = 0 (**arbitrary value**), but not too small
    delta(i) = 1e-4;      
  end
  vU = vX0;                    
  vU(i) = vX0(i) + delta(i);
  dfpp = feval ( fun, vU );     

  vU(i) = vX0(i) - delta(i);
  dfmm = feval ( fun, vU );     
  mH(i,i)= ((dfpp - df) + (dfmm - df)) / (delta(i) * delta(i)); 
  
  for j= 1 : i-1
     % recovers original vX0
    vU = vX0;                    
    vU(i) = vX0(i) + delta(i);
    vU(j) = vX0(j) + delta(j);

    dfpp = feval ( fun, vU );     

    vU(i) = vX0(i) - delta(i);
    vU(j) = vX0(j) - delta(j);
    dfmm = feval ( fun, vU );     
   
    vU(i) = vX0(i) + delta(i);
    vU(j) = vX0(j) - delta(j);
    dfpm = feval ( fun, vU );     
   
    vU(i) = vX0(i) - delta(i);
    vU(j) = vX0(j) + delta(j);
    dfmp = feval ( fun, vU );     
   
     % partial derivatives in symmetric matrix
    mH(i,j)= ((dfpp - dfpm) + (dfmm - dfmp)) / (4*delta(i) * delta(j)); 
    mH(j,i)= mH(i, j);
  end    
end
