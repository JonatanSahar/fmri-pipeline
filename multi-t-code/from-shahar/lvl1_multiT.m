function lvl1_multiT(subIDs,type,TRafterEV,numShuffels)
rng('default')
addpath('niiTool')


% performing each step by calling each of the analysis functions
addpath(genpath('../multit'));

% % set parallel work
% p = gcp('nocreate');
% if numel(p) ==0
%     pool   = parpool('local');
% end
conditions={'hand','percept','ans','speeds','mapping','R_yn','L_yn','R_rt','L_rt','R_fv','L_fv','half_ans'};
condToAnalyze=[12];


% parfor s=1:length(subIDs)
for s=1:length(subIDs)
    for cond=1:length(condToAnalyze)
testMultiTanalysis_semotor_pc_TR1(subIDs{s},conditions{condToAnalyze(cond)},numShuffels,TRafterEV,type)
    end
end
end
