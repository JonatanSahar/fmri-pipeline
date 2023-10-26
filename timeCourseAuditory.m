function timeCourseAuditory()
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

    leftMaskImg.data=niftiread(params.leftRoiMask.path);
    leftMaskImg.info=niftiinfo(params.leftRoiMask.path);

    rightLinearIndex=find(rightMaskImg.data);
    [x,y,z]=ind2sub(size(rightMaskImg.data),rightLinearIndex);
    % These are the locations in 3D of all voxels belonging to the ROI
    rightLocations=[x,y,z];

    leftLinearIndex=find(leftMaskImg.data);
    [x,y,z]=ind2sub(size(leftMaskImg.data),leftLinearIndex);
    % These are the locations in 3D of all voxels belonging to the ROI
    leftLocations=[x,y,z];
    %% Initialize matrices for each combination
    % Trial parameters
    trialLength = 16; % 16 seconds/TRs
    peakActivationTime = 8;
    maxTrials = 20;

    %% load data for each condition
    % base_str = "%d_EV_audiomotor_%d_%sE_%sH.txt";
    % base_str = "%d_EV_audiomotor_*_%s_%s.mat";
    base_str = "%d_EV_auditoryLoc_%d*H.mat"; %101_auditoryLoc_1_log.mat
    log_str = "%d_auditoryLoc_%d.mat";
    ears = ["LE", "RE"];
    % only compute this for experimental runs
    for S = 1:length(params.subjects)
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
            REtrials = T.ear == "R";
            LEtrials = T.ear == "L";
            % load percent-signal-change
%             pscFileName = fullfile(params.timeCourseOutDir, sprintf("%d_PercentSignalChange_%d.nii.gz", subId, runNumber));
            newPscFileName = fullfile(params.multiTOutDir, sprintf("%d_PercentSignalChange_%d_auditoryLoc.nii.gz", subId, runNumber));
%             movefile(pscFileName, newPscFileName);
            pscMatrix = niftiread(newPscFileName);

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
            LETrialData = mean(trialData(:,:,:,:,LEtrials(1:currMinTrials)), 5);
            RETrialData = mean(trialData(:,:,:,:,REtrials(1:currMinTrials)), 5);

            % Average the time course of all voxels in each mask
            % Iterate over each tuple and extract the values across the time dimension

            auditoryCortexMean.leftC.RE = [];
            auditoryCortexMean.leftC.LE = [];
            auditoryCortexMean.rightC.RE = [];
            auditoryCortexMean.rightC.LE = [];
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
                    extractedValues(i, :) = squeeze(LETrialData(locations(i, 1), locations(i, 2), locations(i, 3), :));
                end
                LEMeanTrialDataInMask = mean(extractedValues, 1);

                for i = 1:length(linearIndex)
                    extractedValues(i, :) = squeeze(RETrialData(locations(i, 1), locations(i, 2), locations(i, 3), :));
                end
                REMeanTrialDataInMask = mean(extractedValues, 1);

                auditoryCortexMean.(auditoryCortex).LE = LEMeanTrialDataInMask;
                auditoryCortexMean.(auditoryCortex).RE = REMeanTrialDataInMask;
            end

                data{runNumber}.LE =  LETrialData;
                data{runNumber}.RE =  RETrialData;
                data{runNumber}.auditoryCortexMean =  auditoryCortexMean;
        end % for run

        data_LE = mean(cat(5, data{1}.LE, data{2}.LE), 5);
        data_RE = mean(cat(5, data{1}.RE, data{2}.RE), 5);

        LE_LCortex = mean(cat(1, data{1}.auditoryCortexMean.leftC.LE, data{2}.auditoryCortexMean.leftC.LE));
        LE_RCortex = mean(cat(1, data{1}.auditoryCortexMean.rightC.LE, data{2}.auditoryCortexMean.rightC.LE));
        RE_LCortex = mean(cat(1, data{1}.auditoryCortexMean.leftC.RE, data{2}.auditoryCortexMean.leftC.RE));
        RE_RCortex = mean(cat(1, data{1}.auditoryCortexMean.rightC.RE, data{2}.auditoryCortexMean.rightC.RE));

        info = "The mean across runs of trial activation (in % signal change), averaged within the auditory cortex. Each file represents a single subject";
        % Write to file
        save(fullfile(params.timeCourseOutDir,  sprintf("%d_time_course_auditory", subId)), ...
             "LE_LCortex", ...
             "LE_RCortex", ...
             "RE_LCortex", ...
             "RE_RCortex", ...
             "info", ...
             '-v7.3');

        save(fullfile(params.timeCourseOutDir,  sprintf("%d_time_course_auditory_whole_brain", subId)), ...
             "data_RE", ...
             "data_LE", ...
             '-v7.3');
    end % for subId
end


