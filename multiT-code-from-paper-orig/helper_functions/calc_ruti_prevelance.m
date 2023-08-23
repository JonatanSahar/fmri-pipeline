function Ps = calc_ruti_prevelance(pval_all_subs,u_cutoff) 
% calculates prevalance according to Ruti. 
% input: 'pval_all_subs' is (voxels pvals x subs). 
%        'u_cutof' is percent subs you want significant (between 0-1)
% output: 'Ps' - for each voxel Ruti assigns a pvalue which is the
% signifinacne attached to the hypothesis that this voxle is active in u_cutoff(%) subjects
uval = u_cutoff; 
allpvals = pval_all_subs;
n = size(allpvals,2); 
u = floor(uval *n);
df = 2 * (n-u+1);

% sum of pvals. 
Ps = [];
for i = 1:size(allpvals,1)
    pvals = allpvals(i,:);
    sortpvals = sort(pvals);
    upvals = sortpvals(u:end);
    upvalslog = log(upvals) * (-2);
    sumus = sum(upvalslog);
    Ps(i) = chi2cdf(sumus,df,'upper');
end
end