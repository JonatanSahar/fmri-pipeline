%% params 
clear 
close all
rng('default')
addpath('niiTool')
params.dataDir=fullfile(pwd,'TR1_data');
d=dir(fullfile(params.dataDir,'sub*'));
params.subjects={d.name};
params.numOfRuns=4;
numShuffels=400;
TRafterEV=5;
% TODO: ask Shahar
type='mcRej_nov20';

% %% create group standard mask
% subIDs={params.subjects{[1:3 5:21 23:end]}};
% create_group_standmask(params.dataDir,subIDs)

%% analyze 1st level
subIDs={params.subjects};
lvl1_multiT(subIDs,type,TRafterEV,numShuffels)

%% Group multiT mean
subIDs={params.subjects};
shuff='400';
conditions={'RE_RH','RE_LH', 'LE_RH', 'LE_LH'}; % TODO: how to use this?
condToAnalyze=6;
aveMultiTmap(params.dataDir,subIDs,conditions(condToAnalyze),shuff)

%% 2nd lvl multiT
lvl2_multiT(params,type,TRafterEV,numShuffels)

%% FDR correction
mapDir=fullfile(params.dataDir,['MultiGroupRes/pc_TR1_peakTR' num2str(TRafterEV) '_' 'mcRej_nov20_31N_20.06.2021']);
cmd= ['fdr -i ' fullfile(mapDir,'half_ans_Pmap_pc_TR1_peakTR5_mcRej_nov20.nii')...
    ' -m ' fullfile(params.dataDir,'standard_MNI_mask.nii.gz') ' -q 0.05'];
%% create Pmasks
tresh=0.0001;
create_Pval_mask(mapDir,tresh,TRafterEV)
% create_Pval_mask_forBrainView(mapDir,tresh,TRafterEV)
%% overlap or subtract masks (conditions)
bin_maps=dir(fullfile(outFolder,['*' 'Pmask_trsh01.nii']));
bin_maps={bin_maps(:).name};
map1=bin_maps{2};
map2=bin_maps{1};
map_mult_or_subt(outFolder,map1,map2,1)



%%% visualize maps

dataDir=fullfile(pwd,'/TR1_data/MultiGroupRes/pc_TR1_peakTR5_mcRej_nov20_31N_13.12.2020');
maskfn = fullfile(dataDir,'hand_Pmap_pc_TR1_peakTR5_mcRej_nov20_Pmask_trsh0001.nii');

V = niftiread(maskfn);
tresh=0.0001;
TmapName='L_yn_withneighbours_0001';
create_neighborsP_map(dataDir,maskfn,tresh,TmapName)

