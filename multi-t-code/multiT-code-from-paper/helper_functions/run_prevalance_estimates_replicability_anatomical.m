function run_prevalance_estimates_replicability_anatomical()
% needs neureolf: 
% pvals calcluated with: calcPvalsAllSubs_ar3.m 
p = genpath(pwd); 
addpath(p); 
p = genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\toolboxes\NE_5153'); 
addpath(p); 
ARorder = 6; 
switch ARorder
    case 3
        resultsfold = 'results_VocalDataSet_anatomical_AR3_FFX_ND_norm_100-shuf';
    case 6
        resultsfold = 'results_VocalDataSet_anatomical_AR6_FFX_ND_norm_100-shuf';
end
resultsdir = fullfile('..','..','results',resultsfold);
figfold    = fullfile('..','..','figures',resultsfold);
mkdir(figfold); 

load('idxs_from_havard_cambridge_atlas.mat'); 
ff = findFilesBVQX(resultsdir,'allPvals*.mat');
load(ff{1}); 

uval = 0.70; 
Ps = calc_ruti_prevelance(allpvals,uval); 
sigfdr = fdr_bh(Ps,0.05,'pdep','yes');
plot_ruti_pvals(Ps,allpvals,uval,figfold,ARorder,idxslabelsout); 

%% plot vmp 
mapcnt = 1; 
rawvmp = get_raw_vmp();
tosavevmp = rawvmp;
dataFromAnsMatBackIn3d = scoringToMatrix(mask,sigfdr',locations);
mapfn = sprintf('ruti analyssis u = %f',uval); 
tosavevmp = addmapTovmp(tosavevmp,rawvmp,dataFromAnsMatBackIn3d,mapfn,mapcnt);

tosavevmp.SaveAs(fullfile(resultsdir,'outvmp.vmp'));
end