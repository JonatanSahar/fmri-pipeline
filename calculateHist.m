function calculateHist()
params = setAnalysisParams();
if ~exist(params.timeCourseOutDir)
    mkdir(params.timeCourseOutDir)
end
rng(params.seed);

%% load mask
% Load a mask delineating an ROI, if relevant - can be used to zero-out all non-ROI voxels, for a faster analysis with fewer
% comparisons we'll need to correct for.

rightMaskImg.data=niftiread(params.rightRoiMask.path);
rightMaskImg.info=niftiinfo(params.rightRoiMask.path);
rightLinearIndex=find(rightMaskImg.data);
[x,y,z]=ind2sub(size(rightMaskImg.data),rightLinearIndex);
% These are the locations in 3D of all voxels belonging to the ROI
rightLocations=[x,y,z];

leftMaskImg.data=niftiread(params.leftRoiMask.path);
leftMaskImg.info=niftiinfo(params.leftRoiMask.path);
leftLinearIndex=find(leftMaskImg.data);
[x,y,z]=ind2sub(size(leftMaskImg.data),leftLinearIndex);
% These are the locations in 3D of all voxels belonging to the ROI
leftLocations=[x,y,z];

bilateralMaskImg.data=niftiread(params.bilateralAuditoryCortexMask.path);
bilateralMaskImg.info=niftiinfo(params.bilateralAuditoryCortexMask.path);
bilateralLinearIndex=find(bilateralMaskImg.data);
[x,y,z]=ind2sub(size(bilateralMaskImg.data),bilateralLinearIndex);
% These are the locations in 3D of all voxels belonging to the ROI
bilateralLocations=[x,y,z];


%% Initialize matrices for each combination
% Trial parameters
trialLength = 16; % 16 seconds/TRs
peakActivationTime = 10;
maxTrials = 20;

data_LE = {};
data_RE = {};


%% load data for each condition
% base_str = "%d_EV_audiomotor_%d_%sE_%sH.txt";
% base_str = "%d_EV_audiomotor_*_%s_%s.mat";
base_str = "%d_EV_audiomotor_%d*H.mat"; %101_audiomotor_1_log.mat
log_str = "%d_audiomotor_%d.mat";
ears = ["LE", "RE"];
% only compute this for experimental runs
for S = 1
    subId = params.subjects(S)
    trialData = [];
    LECounter = 1;
    RECounter = 1;
    for runNumber = [1:2]
        functionalDir = sprintf(params.functionalDir, subId);
        EVDir = sprintf(params.rawBehavioralSubjectDir, subId);
        logFilename = sprintf(log_str, ...
            subId,...
            runNumber);
        t = load(fullfile(EVDir,logFilename));
        % filter out disqualified trials
        T =  t.eventTable;
        validIdx = T.had_error == 0;
        T = array2table(T{validIdx, :},'VariableNames', T.Properties.VariableNames);
        ear = sprintf("%sE",T.ear(1));
        RHtrials = T.hand == "R";
        LHtrials = T.hand == "L";

        %% load percent-signal-change data
        pscFileName = fullfile(params.multiTOutDir, sprintf("%d_PercentSignalChange_%d_%s.nii.gz", subId, runNumber, ear));

        % Apply a mask of significant voxels from the multi-t analysis
        if params.bUseSignificantVoxelsOnly
            maskedPscFileName = fullfile(params.multiTOutDir, sprintf("%d_PercentSignalChange_%d_%s_masked.nii.gz", subId, runNumber, ear));
            if ~exist(maskedPscFileName)
                cmd = sprintf("fslmaths %s -mul %s %s", pscFileName, params.significantVoxelsMask.(ear).path, maskedPscFileName)
                system(cmd);
                pscFileName = maskedPscFileName; % override filename
            end
        end

        % Load the matrix
        pscMatrix = niftiread(pscFileName);

        % zeros from the mask, and 0.00001 from the PSC transofrmation will mess with the cross-voxel average
        pscMatrix(pscMatrix == 0 | pscMatrix == 0.00001) = NaN;

        %% extract trial data by time
        % Get the trial start times.
        startTimes = round(str2double(T.start_time));
        maxScanTime = size(pscMatrix, 4);

        % Get the average of the activation along the trial
        % trialData = pscMatrix(:, :, :, startTime:endTime);
        % meanTrialData = mean(trialData, 4);

        % Sample the trial's data where we found it's most likely to peak
        endTimes = startTimes + trialLength;

        % some scans are cut short - find the last actual trial we have
        currMinTrials = max(find(endTimes < maxScanTime));
        endTimes = endTimes(1:currMinTrials);
        for t = 1:length(endTimes)
            currTrialData = pscMatrix(:, :, :, startTimes(t):endTimes(t));
            trialData(:, :, :, :, t) = currTrialData;
        end

        % Average time courses of all trials
        LHTrialData = mean(trialData(:,:,:,:,LHtrials(1:currMinTrials)), 5, 'omitnan');
        RHTrialData = mean(trialData(:,:,:,:,RHtrials(1:currMinTrials)), 5, 'omitnan');

        %% Apply the auditory cortex mask
        auditoryCortexMean.leftC.RH = [];
        auditoryCortexMean.leftC.LH = [];
        auditoryCortexMean.rightC.RH = [];
        auditoryCortexMean.rightC.LH = [];
        for  auditoryCortex = ["leftC", "rightC"]
            switch auditoryCortex
                case "leftC"
                    locations = leftLocations;
                    linearIndex = leftLinearIndex;
                case "rightC"
                    locations = rightLocations;
                    linearIndex = rightLinearIndex;
            end

            for i = 1:length(linearIndex)
                extractedValues(i, :) = squeeze(LHTrialData(locations(i, 1), locations(i, 2), locations(i, 3), :));
            end
            LHValues = extractedValues(:, peakActivationTime);

            for i = 1:length(linearIndex)
                extractedValues(i, :) = squeeze(RHTrialData(locations(i, 1), locations(i, 2), locations(i, 3), :));
            end
            RHValues = extractedValues(:, peakActivationTime);

            auditoryCortexMean.(auditoryCortex).LH = LHValues;
            auditoryCortexMean.(auditoryCortex).RH = RHValues;
        end % for auditory cortex


        switch ear
            case "LE"
                data_LE{LECounter}.auditoryCortexMean =  auditoryCortexMean;
                LECounter = LECounter + 1;
            case "RE"
                data_RE{RECounter}.auditoryCortexMean =  auditoryCortexMean;
                RECounter = RECounter + 1;
        end %switch
    end
end
info = "The peak activation value (approx.) of all tials";
% Write to file
save(fullfile(params.timeCourseOutDir,  sprintf("%d_time_course_hist_data", subId)), ...
    "data_LE", ...
    "data_RE", ...
    "info", ...
    '-v7.3');

end
