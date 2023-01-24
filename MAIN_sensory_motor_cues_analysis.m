clear all; close all; clc;
%%set analysis params
params = setAnalysisParams();

%% create folders for new subjects
createFolders(params);
%% set parameters for the analysis
%% dcm2nii
niiFilesCreate(params);

%% BET
brainExtraction(params);

%% create EVs
params = createEVs(params);  % creates EVs for all conditions
%% pre-processing and first level
p = gcp('nocreate');
if numel(p) ==0
    pool   = parpool('local'); %activate parallel mode
end
runPreProcessing(params);

%% Second level analysis
 runSecondLevel(params);
%% Group analysis
 
%%prepare data for classification
createCommonMask(params);
params = createPercentChangeForSVM(params);
params = analyse_second_lvl(params);