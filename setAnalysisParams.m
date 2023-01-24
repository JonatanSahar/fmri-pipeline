function params=setAnalysisParams()
params.expName = 'analysis-output';
params.seed=2022;
params.subjects=[101:102];

d = dir('..');

params.mainDir=d(1).folder;
params.anatomyFolder='anatomy';
params.functionalFolder='functional';

params.rawBehavioral=fullfile('..','Raw_Data','Behavioral');
params.rawDCM=fullfile('..','Raw_Data');
params.fsfdir=fullfile('..','fsfs');
params.templateDir='/usr/local/fsl/data/standard/MNI152_T1_2mm_brain';

params.conditions = {{'Motor_Only','Auditory_Only','Audio_Motor'},{'Motor_cues', 'Auditory_cues'}};
params.run_nums = [1:2,1:2,1:4];
params.localizerName = params.conditions{1}{3};

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
