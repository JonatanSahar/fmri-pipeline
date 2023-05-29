clear all; close all; clc;
setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin:/home/user/mricron/:']);

%%set analysis params
params = setAnalysisParams();

%% create folders for new subjects
createFolders(params);

createRunOrder(params);

%% dcm2nii
niiFilesCreate(params);

%% BET
brainExtraction(params);

%% create EVs
createEVs(params);  % creates EVs for all conditions
%% pre-processing and first level
% p = gcp('nocreate');
% if numel(p) ==0
%     pool   = parpool('local'); %activate parallel mode
% end
runPreProcessing(params);

%% Second level analysis
 runSecondLevel(params);
%% Group analysis

 
%%prepare data for classification
% createCommonMask(params);
% params = createPercentChangeForSVM(params);
% params = analyse_second_lvl(params);
createMVPAData(params);
