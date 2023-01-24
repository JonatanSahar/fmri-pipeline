function params=setSVMparams()
params.seed=2022;
params.conditions={'motor','auditory'};
params.beamSize=27;
params.hands={'RH','LH'};
params.TRafterStart=5;
params.subjects=1;
params.numOfRuns=3;        
params.commonFolder=fullfile('/media','batel','DATA','sensory_motor_cues','MRI_data'); %common directory of feat output
%mask variables
params.mask.prefix='newMask';
params.mask.dir=fullfile('/media','batel','DATA','sensory_motor_cues','MRI_data','forSVM');
%save variables
params.saveName='_tr5.mat';
params.outDir=fullfile('/media','batel','DATA','sensory_motor_cues','MRI_data','forSVM');
params.savenii=1; %% true for multi-t analysis data
params.useMasking=1;
end