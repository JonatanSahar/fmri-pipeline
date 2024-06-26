function params=setAnalysisParams()
    params.baseDirPath = '/media/user/Data/fmri-data/';
    params.expName = 'analysis-output';
    % params.expName = 'auditorimotor-laterality';
    params.seed=2022;
    
    params.subjects=[101:116];
    % params.subjects=[101:103];
    params.discardedSubjects=[102, 104, 105, 107, 113];
    % params.discardedSubjects=[102, 104, 105, 107, 113];
    params.subjects = setdiff(params.subjects, params.discardedSubjects);

    params.mainDir=params.baseDirPath;

    % d = dir('./data');
    d = dir(params.baseDirPath);

    params.mainDir = d(1);
    params.mainDir = params.mainDir.folder;


    params.anatomyFolder='anatomy';
    params.functionalFolder='functional';

    params.experimentDir=fullfile(params.mainDir, params.expName);
    params.rawDCM=fullfile(params.mainDir,'raw-data');
    params.fsfdir=fullfile(params.mainDir,'fsf-files');
    params.rawBehavioral=fullfile(params.rawDCM, 'behavioral');
    params.templateDir='/home/user/fsl/data/standard/MNI152_T1_2mm_brain';


    params.conditions = ["motorLoc", "auditoryLoc", "audiomotor"];
    params.numRunsPerCondition = [2, 2, 4];
    params.conditionsInOrder = [1, 1, 2, 2, 3, 3, 3, 3];

    % params.conditions = ["auditoryLoc"];
    % params.numRunsPerCondition = [1];

    subjectDir    = fullfile(params.experimentDir,"%d");
    sessionDir    = fullfile(subjectDir,'session_1');
    anatomyDir    = fullfile(subjectDir,'anatomy');
    EVDir         = fullfile(subjectDir,'EVs');
    functionalDir = fullfile(subjectDir,'functional');

    rawBehavioralSubjectDir    = fullfile(params.rawBehavioral,"%d");

    params.sessionDir    =  strrep(sessionDir, "\", "\\");
    params.EVDir         =  strrep(EVDir, "\", "\\");
    params.anatomyDir    =  strrep(anatomyDir, "\", "\\");
    params.subjectDir    =  strrep(subjectDir, "\", "\\");
    params.functionalDir =  strrep(functionalDir, "\", "\\");
    params.rawBehavioralSubjectDir =  strrep(rawBehavioralSubjectDir, "\", "\\");

    for sub = 1:length(params.subjects)
        if false
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
    params.mask.name='MNI152_T1_2mm_brain_mask.nii.gz';
    params.mask.dir=fullfile(params.mainDir,params.expName);
    params.mask.path= "/media/user/Data/fmri-data/analysis-output/MNI-brain-mask/standard_mask.nii.gz";
    params.leftRoiMask.path= "/media/user/Data/fmri-data/analysis-output/L_auditory_cortex_mask.nii.gz";
    params.rightRoiMask.path= "/media/user/Data/fmri-data/analysis-output/R_auditory_cortex_mask.nii.gz";
    params.bilateralAuditoryCortexMask.path = "/media/user/Data/fmri-data/analysis-output/combined_auditory_cortex_mask.nii.gz";
    params.significantVoxelsMask.LE.path = "/media/user/Data/fmri-data/analysis-output/multi-t-results/audiomotor/LE_significant_bin_mask.nii.gz";
    params.significantVoxelsMask.RE.path = "/media/user/Data/fmri-data/analysis-output/multi-t-results/audiomotor/RE_significant_bin_mask.nii.gz";
    params.significantVoxelsMask.bilateral.path = "/media/user/Data/fmri-data/analysis-output/multi-t-results/audiomotor/bilateral_significant_bin_mask.nii.gz";
    params.significantVoxelsMask.motor.path = "/media/user/Data/fmri-data/analysis-output/multi-t-results/motor-only/motor_significant_bin_mask.nii.gz";

    %% multi T params
    params.numShuffels = 10;
    %save variables
    params.saveName='_tr10.mat';
    params.outDir=fullfile(params.mainDir,params.expName,'SVM-data');
    params.timeCourseOutDir=fullfile(params.mainDir,params.expName,'time-course-results');
    params.multiTOutDir=fullfile(params.mainDir,params.expName,'multi-t-data', "audiomotor");
    params.multiTOutDirAuditory=fullfile(params.mainDir,params.expName,'multi-t-data', "auditory-only");
    params.multiTOutDirMotor=fullfile(params.mainDir,params.expName,'multi-t-data', "motor-only");
    params.savenii=0; %% true for multi-t analysis data
    params.useMasking=1;
    params.bUseSignificantVoxelsOnly = 1;
end
