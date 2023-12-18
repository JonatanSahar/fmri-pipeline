function computeTimeCourseMotor()
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
    peakActivationTime = 8;
    maxTrials = 20;

    %% load data for each condition
    % base_str = "%d_EV_audiomotor_%d_%sE_%sH.txt";
    % base_str = "%d_EV_audiomotor_*_%s_%s.mat";
    base_str = "%d_EV_motorLoc_%d*H.mat"; %101_motorLoc_1_log.mat
    log_str = "%d_motorLoc_%d.mat";

    % only compute this for experimental runs
    for S = 1:length(params.subjects)
        subId = params.subjects(S)
        trialData = [];
        LHCounter = 1;
        RHCounter = 1;
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
            hand = sprintf("%sE",T.hand(1));
            RHtrials = T.hand == "R";
            LHtrials = T.hand == "L";

            %% load percent-signal-change data
            pscFileName = fullfile(params.multiTOutDirMotor, sprintf("%d_PercentSignalChange_%d_motorLoc.nii.gz", subId, runNumber));

            % Apply a mask of significant voxels from the multi-t analysis
            if params.bUseSignificantVoxelsOnly
                maskedPscFileName = fullfile(params.multiTOutDirMotor, sprintf("%d_PercentSignalChange_%d_motorLoc_masked.nii.gz", subId, runNumber));
                if ~exist(maskedPscFileName)
                cmd = sprintf("fslmaths %s -mul %s %s", pscFileName, params.significantVoxelsMask.bilateral.path, maskedPscFileName)
                    system(cmd);
                    pscFileName = maskedPscFileName; % override filename
                end
            end

            % Load the matrix
            pscMatrix = niftiread(pscFileName);

            % zeros from the mask, and 0.00001 from the PSC transofrmation will mess with the cross-voxel average
            pscMatrix(pscMatrix == 0 | pscMatrix == 0.00001) = NaN;

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

            % Average the time course of all voxels in each mask
            % Iterate over each tuple and extract the values across the time dimension

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
                LHMeanTrialDataInMask = mean(extractedValues, 1, "omitnan");

                for i = 1:length(linearIndex)
                    extractedValues(i, :) = squeeze(RHTrialData(locations(i, 1), locations(i, 2), locations(i, 3), :));
                end
                RHMeanTrialDataInMask = mean(extractedValues, 1, "omitnan");

                auditoryCortexMean.(auditoryCortex).LH = LHMeanTrialDataInMask;
                auditoryCortexMean.(auditoryCortex).RH = RHMeanTrialDataInMask;
            end

                data{runNumber}.LH =  LHTrialData;
                data{runNumber}.RH =  RHTrialData;
                data{runNumber}.auditoryCortexMean =  auditoryCortexMean;
        end % for run

        data_LH = mean(cat(5, data{1}.LH, data{2}.LH), 5);
        data_RH = mean(cat(5, data{1}.RH, data{2}.RH), 5);

        LH_LCortex = mean(cat(1, data{1}.auditoryCortexMean.leftC.LH, data{2}.auditoryCortexMean.leftC.LH));
        LH_RCortex = mean(cat(1, data{1}.auditoryCortexMean.rightC.LH, data{2}.auditoryCortexMean.rightC.LH));
        RH_LCortex = mean(cat(1, data{1}.auditoryCortexMean.leftC.RH, data{2}.auditoryCortexMean.leftC.RH));
        RH_RCortex = mean(cat(1, data{1}.auditoryCortexMean.rightC.RH, data{2}.auditoryCortexMean.rightC.RH));

        info = "The mean across runs of trial activation (in % signal change), averaged within the auditory cortex. Each file represents a single subject";
        % Write to file
        save(fullfile(params.timeCourseOutDir,  sprintf("%d_time_course_motor", subId)), ...
             "LH_LCortex", ...
             "LH_RCortex", ...
             "RH_LCortex", ...
             "RH_RCortex", ...
             "info", ...
             '-v7.3');

        save(fullfile(params.timeCourseOutDir,  sprintf("%d_time_course_motor_whole_brain", subId)), ...
             "data_RH", ...
             "data_LH", ...
             '-v7.3');
    end % for subId
end


