function createMultiTDataMotor()
% This function transforms each subject's first level COPE data into percent-signa-change format in MNI152 space (without clipping it to the MNI152 mask).
% It then extract a certain timepoint from each trial, estimated to represent peak BOLD activation, and labels that timepoint based on the hand used in that trial - LH or RH
% It output is a .mat file per subject containing all of the data points and an associated labels vector

    params = setAnalysisParams();
    if ~exist(params.multiTOutDirMotor)
        mkdir(params.multiTOutDirMotor)
    end
    rng(params.seed);

    %% load mask
    % Load a mask delineating an ROI, if relevant - can be used to zero-out all non-ROI voxels, for a faster analysis with fewer comparisons we'll need to correct for.

    % maskImg.data=niftiread(params.rightRoiMask);
    % maskImg.info=niftiinfo(params.rightRoiMask);

    % maskImg.data=niftiread(params.leftRoiMask);
    % maskImg.info=niftiinfo(params.leftRoiMask);

    % linearIndex=find(maskImg.data);
    % [x,y,z]=ind2sub(size(maskImg.data),linearIndex);
    % These are the locations in 3D of all voxels belonging to the ROI
    % locations=[x,y,z];

    %% Trial parameters
    trialLength = 16; % 16 seconds/TRs
    peakActivationTime = 8;
    maxTrials = 20;


    %% load data for each condition
    log_str = "%d_motorLoc_%d.mat"; %101_audiomotor_1_log.mat
    hands = ["LH", "RH"];
    % only compute this for experimental runs
    for S = 1:length(params.subjects)
        subId = params.subjects(S)
        % Initialization - here because of parallel computing
        data = [];
        labels = [];
        pscMatrix = [];
        metadata = [];
        for runNumber = [1:2]
            functionalDir = sprintf(params.functionalDir, subId);
            % take the event table file from the *raw* behavioral data dir. It hasn't been copied into  analysis-output
            rawEVDir = sprintf(params.rawBehavioralSubjectDir, subId);
            logFilename = sprintf(log_str, ...
                                  subId,...
                                  runNumber);
            t = load(fullfile(rawEVDir,logFilename));
            % filter out disqualified trials
            T =  t.eventTable;
            validIdx = T.had_error == 0;
            T = array2table(T{validIdx, :},'VariableNames', T.Properties.VariableNames);
            minTrials = maxTrials;
            % transform the scan to MNI space
            featDir = fullfile(functionalDir, ...
                               sprintf("sub%d_motorLoc_%d.feat", ...
                                       subId, ...
                                       runNumber));
            if ~exist(fullfile(featDir,'filtered_func_data_MNI.nii.gz'),'file') || params.override
                tranformFeatDirToMNI(featDir)
            else
                fprintf('MNI transform for subject %d run no. %d already exists\n', subId, runNumber)
            end

            % calculate percent-signal-change
            pscFileName = fullfile(params.multiTOutDirMotor, sprintf("%d_PercentSignalChange_%d.nii.gz", subId, runNumber));
            if ~exist(pscFileName, "file")
                functionalDataPath = fullfile(featDir,'filtered_func_data_MNI.nii.gz');
                fprintf("reading from %d, run %d\n", subId, runNumber)
                functionalData = niftiread(functionalDataPath);
                fprintf("done reading from %d, run %d\n", subId, runNumber)
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
            runLabels(T.hand == "L") = 1; % label LH trials as "1"\
            runLabels(T.hand == "R") = 0;
            runLabels = runLabels(1:currMinTrials);
            data =  cat(4, data, trialPeakData);
            labels = cat(2, labels, runLabels);
        end % for run

        size(labels)
        size(data)

        % suffix to variable names for interop with existing  multiT code
        data_motor = data;
        labels_motor = labels;

        % Write to file
        save(fullfile(params.multiTOutDirMotor,  sprintf("%d_multiT_data_and_labels", subId)), ...
             "data_motor", ...
             "labels_motor", ...
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
        D = load(fullfile(params.multiTOutDirMotor, ...
                          sprintf("%d_multiT_data_and_labels", subId)));
        for cond = ["data", "labels"]
            data_motor = D.data;
            labels_motor = D.labels;
            save(fullfile(params.multiTOutDirMotor, ...
                          sprintf("%d_multiT_data_and_labels", subId)), data_motor, labels_motor, '-v7.3');
        end
    end
end
