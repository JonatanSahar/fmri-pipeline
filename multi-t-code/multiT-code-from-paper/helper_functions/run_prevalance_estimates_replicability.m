function run_prevalance_estimates_replicability()
% needs neureolf: 
p = genpath(pwd); 
addpath(p); 
p = genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\toolboxes\NE_5153'); 
addpath(p); 

% load matfile with pvalues: 
% fn_pvals = 'allPvals_FIR_ar3_150subs.mat';
% resultsdir = 'results_VocalDataSet_FFX_ND_FIR_AR3_400-shuf_SL-27'; 
% fullpathresultsdir = fullfile('..','results',resultsdir);
% load(fullfile('..','results',resultsdir,fn_pvals));

resultsdir = fullfile('..','..','results','results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-27');
ff = findFilesBVQX(resultsdir,'allPvals*.mat'); 
load(ff{1}); 

% get real values second level 
% ff = findFilesBVQX(analysisfolder,'ND*.mat');
% load(ff{1},'avgAnsMat','mask','locations');
% realvals = avgAnsMat(:,1); 

% plotpvals of each subject 
% figure;cnt =1;
% for i = 1:size(allPvals,2)
%     subplot(4,5,cnt); cnt = cnt + 1; 
%     histogram(allPvals(:,i));
% end
% allPvals = allPvals(:,randSubs);
uval = 0.6; 

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
sigfdr = fdr_bh(Ps,0.05,'pdep','yes');
%% plot vmp 
mapcnt = 1; 
rawvmp = get_raw_vmp();
tosavevmp = rawvmp;
dataFromAnsMatBackIn3d = scoringToMatrix(mask,sigfdr',locations);
mapfn = sprintf('ruti analyssis u = %f',uval); 
tosavevmp = addmapTovmp(tosavevmp,rawvmp,dataFromAnsMatBackIn3d,mapfn,mapcnt);

tosavevmp.SaveAs(fullfile(fullpathresultsdir,'outvmp.vmp'));
end