function createMultiTData()
    params = setAnalysisParams()
    if ~exist(params.multiTOutDir)
        mkdir(params.multiTOutDir)
    end
    rng(params.seed);

    %% load mask
    % Load a mask delineating an ROI, if relevant - can be used to zero-out all non-ROI voxels, for a faster analysis with fewer
    % comparisons we'll need to correct for.

    % maskImg.data=niftiread(params.rightRoiMask);
    % maskImg.info=niftiinfo(params.rightRoiMask);

    % maskImg.data=niftiread(params.leftRoiMask);
    % maskImg.info=niftiinfo(params.leftRoiMask);

    % linearIndex=find(maskImg.data);
    % [x,y,z]=ind2sub(size(maskImg.data),linearIndex);
    % These are the locations in 3D of all voxels belonging to the ROI
    % locations=[x,y,z];

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
        % Initialization - here because of parallel computing
        data_LE = [];
        data_RE = [];
        pscMatrix = [];
        metadata = [];
        labels_RE = [];
        labels_LE = [];
        for runNumber = [1:4]
            labels = zeros(1,maxTrials);
            % for ear = ears
            functionalDir = sprintf(params.functionalDir, subId);
            % for runNumber = 1:numRuns
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
            minTrials = maxTrials;
            % transform the scan to MNI space
            featDir = fullfile(functionalDir, ...
                               sprintf("sub%d_audiomotor_%d_%s.feat", ...
                                       subId, ...
                                       runNumber, ...
                                       ear));
            if ~exist(fullfile(featDir,'filtered_func_data_MNI.nii.gz'),'file') || params.override
                tranformFeatDirToMNI(featDir)
            else
                fprintf('MNI transform for subject %d run no. %d already exists\n', subId, runNumber)
            end

            % calculate percent-signal-change
            pscFileName = fullfile(params.multiTOutDir, sprintf("%d_PercentSignalChange_%d.nii.gz", subId, runNumber));
            if ~exist(pscFileName, "file")
                functionalDataPath = fullfile(featDir,'filtered_func_data_MNI.nii.gz');
                fprintf("reading from %d, run %d", subId, runNumber)
                functionalData = niftiread(functionalDataPath);
                fprintf("done reading from %d, run %d", subId, runNumber)
                metadata = niftiinfo(functionalDataPath);
                pscMatrix = calcPercentSignalChange(functionalData);
                niftiwrite(pscMatrix, pscFileName, metadata, 'Compressed',true);
            else
                pscMatrix = niftiread(pscFileName);
            end

            % Get the trial start times.
            startTimes = round(str2double(T.start_time));
            maxScanTime = size(pscMatrix, 4);
            % Get the average of the activation along the trial
            % trialData = pscMatrix(:, :, :, startTime:endTime);
            % meanTrialData = mean(trialData, 4);

            % Sample the trial's data where we found it's most likely to peak
            peakActivationTimes = startTimes + peakActivationTime;
            % some scans are cut short - find the last actual trial we have
            currMinTrials = max(find(peakActivationTimes < maxScanTime));
            peakActivationTimes = peakActivationTimes(1:currMinTrials);
            if currMinTrials < minTrials
                minTrials = currMinTrials;
            end
            trialPeakData = pscMatrix(:, :, :, peakActivationTimes);
            labels(find(T.hand == "L")) = 1; % label LH trials as "1"
            labels = labels(1:currMinTrials);
            switch ear
              case "LE"
                data_LE =  cat(4, data_LE, trialPeakData);
                labels_LE = cat(2, labels_LE, labels);
              case "RE"
                data_RE =  cat(4, data_RE, trialPeakData);
                labels_RE = cat(2, labels_RE, labels);
            end %switch
        end % for run

        % if (minTrials < maxTrials)
        %     data_RE = data_RE(:,:,:,1:minTrials);
        %     labels_RE = labels_RE(:,:,:,1:minTrials);
        %     data_LE = data_LE(:,:,:,1:minTrials);
        %     labels_LE = labels_LE(:,:,:,1:minTrials);
        % end

        size(labels_LE)
        size(data_LE)

        % Write to file
        save(fullfile(params.multiTOutDir,  sprintf("%d_multiT_data_and_labels", subId)), ...
             "data_LE", ...
             "data_RE", ...
             "labels_LE", ...
             "labels_RE", ...
             'params', ...
             '-v7.3');
    end % for subId
end


function tranformFeatDirToMNI(featDir)
    cmd = sprintf('applywarp -i %s -o %s -r %s --warp=%s --premat=%s', ...
                  fullfile(featDir, 'filtered_func_data.nii.gz'), ...
                  fullfile(featDir, 'filtered_func_data_MNI.nii.gz'), ...
                  fullfile(featDir, 'reg', 'standard'), ...
                  fullfile(featDir, 'reg', 'highres2standard_warp'), ...
                  fullfile(featDir, 'reg', 'example_func2highres.mat'));
    fprintf("executing:\n%s\n", cmd)
    unix(cmd);
end

function percentChangeData =calcPercentSignalChange(functionalData)
    if any(any(any(any(functionalData==0))))
        zeroLocs=find(functionalData==0);
        disp(['this scan has ', num2str(length(zeroLocs)),' zero voxels']);
        functionalData(zeroLocs)=0.00001;
    end
    percentChangeData=functionalData./mean(functionalData,4)*100-100;
end


% extract the files we need as input to the multi-t algorithm
function extractMultiTData(params)
    for subId = params.subjects(1)
        D = load(fullfile(params.multiTOutDir, ...
                          sprintf("%d_multiT_data_and_labels", subId)));
        for cond = ["data_all_LE", "data_all_RE", "labels_all_LE", "labels_all_RE"]
            t = D.(cond)
            save(fullfile(params.multiTOutDir,  sprintf("%d_%s", subId, cond)), cond, '-v7.3');
        end
    end
end
