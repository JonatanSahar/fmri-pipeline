function [Tstat] = calcTstatMuniMengTwoGroup_v2(x,y)
%% this is another version based on convo with JR on 2/2/2017
% main difference is that: 
% That here we assume that both groups may have unequal covariances
% And we apply Strivasav and Du correction: 
% Formula 1.19 out of: 
% Strivasava 2013 a two sample test of HD data 
% compute some base values
% rows are trials, columns are voxels 
invDiag = @(x) (1./x) .*(eye(size(x)));

xmean = mean(x,1); 
ymean = mean(y,1); 
deltamean = xmean-ymean;
Nx   = size(x,1);
Ny   = size(y,1);
sx   = cov(x);
sy   = cov(y);
Dx   = diag(sx);
Dy   = diag(sy); 
D    = Dx/Nx + Dy/Ny; 
Dinv = 1./D; 
sqrtDinv = sqrt(Dinv); 
n = Nx + Ny - 2;
S = (sx/Nx) + (sy/Ny);
p = size(x,2);


R  = sqrtDinv * sqrtDinv' .* S;
Rx = sqrtDinv * sqrtDinv' .* sx;
Ry = sqrtDinv * sqrtDinv' .* sy;
traceR2ofCorrDelta = trace(R'*R); 
vq1 = (2 * traceR2ofCorrDelta )/ p;
vq2 = (2 /(p * Nx^2 * (Nx-1)))  * trace(Rx)^2;
vq3 = (2 /(p * Ny^2 * (Ny-1)))  * trace(Ry)^2;
vq  = vq1 - vq2 - vq3; 
%% calculate stat Muni meng:
%numerator =  1/(1/Nx + 1/Ny) * deltamean * dinv * deltamean' - p;
numerator =   sum((deltamean'.^2)./D) - p;
cPn = 1 +  ( traceR2ofCorrDelta/ (p^(3/2)) );
denminatr = sqrt(p * vq * cPn); 

Tstat(1) = numerator / denminatr; 
%Tstat(2) = numerator;
%Tstat(3) = sqrt(denminatr * cPn);

end