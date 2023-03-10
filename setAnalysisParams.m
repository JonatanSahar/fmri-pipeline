function params=setAnalysisParams()
    params.baseDirPath = '/media/user/Data/fmri-data/';
    params.expName = 'analysis-output';
    % params.expName = 'auditorimotor-laterality';
    params.seed=2022;
    params.subjects=[101];
    params.mainDir=params.baseDirPath;

    % d = dir('./data');
    d = dir(params.baseDirPath);

    params.mainDir = d(1)
    params.mainDir = params.mainDir.folder;


    params.anatomyFolder='anatomy';
    params.functionalFolder='functional';

    params.experimentDir=fullfile(params.mainDir, params.expName);
    params.rawDCM=fullfile(params.mainDir,'raw-data');
    params.fsfdir=fullfile(params.mainDir,'fsf-files');
    params.rawBehavioral=fullfile(params.rawDCM, 'behavioral');
    params.templateDir='/home/user/fsl/data/standard/MNI152_T1_2mm_brain'


    params.conditions = ["motorLoc", "auditoryLoc", "audiomotor"];
    % params.conditions = ["motor_loc", "auditory_loc", "audiomotor"];
    params.numRunsPerCondition = [2, 2, 4];

    % params.conditionsInOrder = [1,2,3,3];
    params.conditionsInOrder = [1, 1, 2, 2, 3, 3, 3, 3];
    params.sides = {'R', 'L'}
    params.runNumsLocalizers = [1:2];
    params.runNumsAudiomotor = [1:4];
    params.run_nums = [params.runNumsLocalizers, params.runNumsLocalizers, params.runNumsAudiomotor];

    subjectDir    = fullfile(params.experimentDir,"%d")
    sessionDir    = fullfile(subjectDir,'session_1');
    anatomyDir    = fullfile(subjectDir,'anatomy');
    EVDir         = fullfile(subjectDir,'EVs');
    functionalDir = fullfile(subjectDir,'functional');

    params.sessionDir    =  strrep(sessionDir, "\", "\\");
    params.EVDir         =  strrep(EVDir, "\", "\\");
    params.anatomyDir    =  strrep(anatomyDir, "\", "\\");
    params.subjectDir    =  strrep(subjectDir, "\", "\\");
    params.functionalDir =  strrep(functionalDir, "\", "\\");

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

    %%FEAt params
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
