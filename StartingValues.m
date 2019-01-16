function [vp, aparnames] = StartingValues(vinput, vp0)
idistribution = vinput(1);
ilinkfunction = vinput(2);
ip = vinput(4);
iq = vinput(5);
domega = vp0(1);
vA = vp0(2:ip+1);
vB = vp0(2+ip:ip+iq+1);
dmu = vp0(4);
ddf = vp0(5);
if ilinkfunction == 2 %SIGMA: In this case omega is estimated with exp(omega)
    if domega <= 0 
        domega = -10;
    else
        domega = log(domega);       
    end
end

if size(vA,1) ~= ip || size(vB,1) ~= iq
	disp('Number of starting values in vector vA, vB must be equal to ip, iq');
	error('Program terminated');
end

if sum(vB) > 1
	disp('Sum of elements in vector vB cannot exceed 1');
	error('Program terminated');
end

asA = cell(ip, 1);
asA(:) = {''};
asB = cell(iq, 1);
asB(:) = {''};

for i = 1:ip
    asA(i) = strcat('A',{num2str(i)});
end 
for i = 1:iq
    asB(i) = strcat('B',{num2str(i)});
end 
	
if idistribution == 0 %GAUSS
    vp = [domega ; vA ; vB ; dmu];
    aparnames = cat(1, 'omega', asA, asB, 'mu');
	return
end
if idistribution == 1 %STUD_T
    vp = [domega ; vA ; vB ; dmu ; ddf];
    aparnames = cat(1, 'omega', asA, asB, 'mu', 'df');
	return
end
