function params=setAnalysisParams()
params.baseDirPath = '/media/user/Data/fmri-data/';
params.expName = 'analysis-output';
params.seed=2022;
params.subjects=[100];

% d = dir('./data');
% params.mainDir = d(1)
% params.mainDir = params.mainDir.folder;

params.mainDir=params.baseDirPath;

params.anatomyFolder='anatomy';
params.functionalFolder='functional';

params.experimentDir=fullfile(params.mainDir, params.expName);
params.rawDCM=fullfile(params.mainDir,'raw-data');
params.fsfdir=fullfile(params.mainDir,'fsfs');
params.rawBehavioral=fullfile(params.rawDCM, 'behavioral');
params.templateDir='/usr/local/fsl/data/standard/MNI152_T1_2mm_brain';

% params.conditions{1} = conditions
% params.conditions{2} = hands
% params.conditions{2} = ears
params.conditions = {
    {'motor_loc', 'auditory_loc', 'audiomotor'}; ...
    [1, 1, 2]}; ...
    % {2, 2, 4} ...
    % {{'R', 'L'}, {'none', 'none'}, {'R', 'L'}}; ...
    % {{'none', 'none'}, {'R', 'L'}, {'R', 'L'}}};

params.conditionsInOrder = [1,2,3];
% params.conditionsInOrder = {1, 1, 2, 2, 3, 3, 3, 3};
params.sides = {'R', 'L'}
params.runNumsLocalizers = [1:2];
params.runNumsAudiomotor = [1:4];
params.run_nums = [params.runNumsLocalizers, params.runNumsLocalizers, params.runNumsAudiomotor];
params.localizer1Name = params.conditions{1}{1};
params.localizer2Name = params.conditions{1}{2};

for sub = 1:length(params.subjects)
    if false
    % was: if params.subjects(sub) == 101 || params.subjects(sub) == 102
        params.alt_DCM_order{1,sub} = [4:8,1:3];
    else
        params.alt_DCM_order{1,sub} = [];
    end
    params.alt_DCM_order{2,sub} = [];
    
end

% params.alt_DCM_order = {[4:8,1:3],[4:8,1:3]};
% params.alt_DCM_order(2,:) = {[],[]};

params.override = 0;

params.fieldMap=0;
params.smoothing=5;
params.normalization=1;

%% svm params
params.beamSize=27;
params.laterality={'_RIGHT','_LEFT'};
params.TRafterStart=10;
params.numOfRuns=3;        
%mask variables
params.mask.name='commonAllSubs.nii.gz';
params.mask.dir=fullfile(params.mainDir,params.expName);
%save variables
params.saveName='_tr10.mat';
params.outDir=fullfile(params.mainDir,params.expName,'forSVM');
params.savenii=0; %% true for multi-t analysis data
params.useMasking=1;



end
