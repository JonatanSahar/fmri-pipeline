function computeTimeCourse()
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
    base_str = "%d_EV_audiomotor_%d*H.mat"; %101_audiomotor_1_log.mat
    log_str = "%d_audiomotor_%d.mat";
    ears = ["LE", "RE"];
    % only compute this for experimental runs
    for S = 1:length(params.subjects)
        subId = params.subjects(S)
        trialData = [];
        LECounter = 1;
        RECounter = 1;
        for runNumber = [1:4]
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
            % load percent-signal-change
            pscFileName = fullfile(params.multiTOutDir, sprintf("%d_PercentSignalChange_%d_%s.nii.gz", subId, runNumber, ear));

            if params.bUseSignificantVoxelsOnly
                % Apply a mask of significant voxels from the multi-t analysis
                maskedPscFileName = fullfile(params.multiTOutDir, sprintf("%d_PercentSignalChange_%d_%s_masked.nii.gz", subId, runNumber, ear));
                cmd = sprintf("fslmaths %s -mul %s %s", pscFileName, params.significantVoxelsMask.(ear).path, maskedPscFileName)
                system(cmd);
                pscMatrix = niftiread(maskedPscFileName);
            else
                pscMatrix = niftiread(pscFileName);
            end

            pscMatrix(pscMatrix == 0) = NaN;

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

                if ~params.bUseSignificantVoxelsOnly
                    % Manually mask the results with the auditory localizer results
                    for i = 1:length(linearIndex)
                        extractedValues(i, :) = squeeze(LHTrialData(locations(i, 1), locations(i, 2), locations(i, 3), :));
                    end
                    LHMeanTrialDataInMask = mean(extractedValues, 1);

                    % Manually mask the results with the auditory localizer results
                    for i = 1:length(linearIndex)
                        extractedValues(i, :) = squeeze(RHTrialData(locations(i, 1), locations(i, 2), locations(i, 3), :));
                    end
                    RHMeanTrialDataInMask = mean(extractedValues, 1);

                    auditoryCortexMean.(auditoryCortex).LH = LHMeanTrialDataInMask;
                    auditoryCortexMean.(auditoryCortex).RH = RHMeanTrialDataInMask;
                else
                    auditoryCortexMean.(auditoryCortex).LH = mean(LHTrialData, 1, "omitnan");
                    auditoryCortexMean.(auditoryCortex).RH = mean(RHTrialData, 1, "omitnan");
                end
            end % for auditory cortex

            switch ear
              case "LE"
                data_LE{LECounter}.LH =  LHTrialData;
                data_LE{LECounter}.RH =  RHTrialData;
                data_LE{LECounter}.auditoryCortexMean =  auditoryCortexMean;
                LECounter = LECounter + 1;
              case "RE"
                data_RE{RECounter}.LH =  LHTrialData;
                data_RE{RECounter}.RH =  RHTrialData;
                data_RE{RECounter}.auditoryCortexMean =  auditoryCortexMean;
                RECounter = RECounter + 1;
            end %switch
        end % for run

        LE_LH = mean(cat(5, data_LE{1}.LH, data_LE{2}.LH), 5);
        LE_RH = mean(cat(5, data_LE{1}.RH, data_LE{2}.RH), 5);
        RE_LH = mean(cat(5, data_RE{1}.LH, data_RE{2}.LH), 5);
        RE_RH = mean(cat(5, data_RE{1}.RH, data_RE{2}.RH), 5);

        LE_LCortex_LH = mean(cat(1, data_LE{1}.auditoryCortexMean.leftC.LH, data_LE{2}.auditoryCortexMean.leftC.LH));
        LE_LCortex_RH = mean(cat(1, data_LE{1}.auditoryCortexMean.leftC.RH, data_LE{2}.auditoryCortexMean.leftC.RH));
        LE_RCortex_LH = mean(cat(1, data_LE{1}.auditoryCortexMean.rightC.LH, data_LE{2}.auditoryCortexMean.rightC.LH));
        LE_RCortex_RH = mean(cat(1, data_LE{1}.auditoryCortexMean.rightC.RH, data_LE{2}.auditoryCortexMean.rightC.RH));
        RE_LCortex_LH = mean(cat(1, data_RE{1}.auditoryCortexMean.leftC.LH, data_RE{2}.auditoryCortexMean.leftC.LH));
        RE_LCortex_RH = mean(cat(1, data_RE{1}.auditoryCortexMean.leftC.RH, data_RE{2}.auditoryCortexMean.leftC.RH));
        RE_RCortex_LH = mean(cat(1, data_RE{1}.auditoryCortexMean.rightC.LH, data_RE{2}.auditoryCortexMean.rightC.LH));
        RE_RCortex_RH = mean(cat(1, data_RE{1}.auditoryCortexMean.rightC.RH, data_RE{2}.auditoryCortexMean.rightC.RH));

        info = "The mean across runs of trial activation (in % signal change), averaged within the auditory cortex. Each file represents a single subject";
        % Write to file
        save(fullfile(params.timeCourseOutDir,  sprintf("%d_time_course", subId)), ...
             "LE_LCortex_LH", ...
             "LE_LCortex_RH", ...
             "LE_RCortex_LH", ...
             "LE_RCortex_RH", ...
             "RE_LCortex_LH", ...
             "RE_LCortex_RH", ...
             "RE_RCortex_LH", ...
             "RE_RCortex_RH", ...
             "info", ...
             '-v7.3');

        save(fullfile(params.timeCourseOutDir,  sprintf("%d_time_course_whole_brain", subId)), ...
             "LE_RH", ...
             "LE_LH", ...
             "RE_RH", ...
             "RE_LH", ...
             '-v7.3');
    end % for subId
end


