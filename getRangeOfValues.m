function getRangeOfValues()
    params = setAnalysisParams();
    base_str = "%d_EV_audiomotor_%d*H.mat"; %101_audiomotor_1_log.mat
    log_str = "%d_audiomotor_%d.mat";
    trialLength = 16; % 16 seconds/TRs
    peakActivationTime = 8;
    maxTrials = 20;

    for S = 1
        subId = params.subjects(S);
        trialData = [];

        for runNumber = 1
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
            trials = T.hand == "R" | T.hand == "L";

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
            meanTrialData = mean(trialData(:,:,:,:,trials(1:currMinTrials)), 5, 'omitnan');
            histogram(meanTrialData);

            info = "";
            % Write to file
            save(fullfile(params.timeCourseOutDir,  sprintf("%d_histogram", subId)), ...
                 "info", ...
                 '-v7.3');
        end
    end
    
end
