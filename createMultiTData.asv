function createMultiTData(params)

    if ~exist(params.outDir)
        mkdir(params.outDir)
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
    maxTrials = 10;

    % Initialization
    labels_LE_LH = zeros(1,maxTrials); % LE_LH = 1;
    labels_LE_RH = zeros(1,maxTrials); % LE_RH = 2;
    labels_RE_LH = zeros(1,maxTrials); % RE_LH = 3;
    labels_RE_RH = zeros(1,maxTrials); % RE_RH = 4;
    data_LE_LH = [];
    data_LE_RH = [];
    data_RE_LH = [];
    data_RE_RH = [];
    pscMatrix = [];
    metadata = [];
    
    %% load data for each condition
    % base_str = "%d_EV_audiomotor_%d_%sE_%sH.txt";
    base_str = "%d_EV_audiomotor_*_%s_%s.mat";
    log_str = "%d_audiomotor_%d_log.mat";
    ears = ["LE", "RE"];
    % only compute this for experimental runs
    for subId = params.subjects
        for ear = ears
            functionalDir = sprintf(params.functionalDir, subId);
            hands = ["LH", "RH"];
            for hand = hands
                % for runNumber = 1:numRuns
                EVDir = sprintf(params.EVDir, subId);
                EVFilename = sprintf(base_str, ...
                                     subId,...
                                     ear,...
                                     hand);

                % Go over all files with this ear-hand combination
                % Each file is a unique (run, hand) (run ⇒ ear)
                files = dir(fullfile(EVDir,EVFilename));
                for f = 1:length(files)
                    EVFile = files(f)
                    t = strsplit(EVFile.name, '_');
                    runNumber = str2double(t{4});
                    featDir = fullfile(functionalDir, ...
                                       sprintf("sub%d_audiomotor_%d_%s.feat", ...
                                               subId, ...
                                               runNumber, ...
                                               ear));

                    % Get the log file for this run
                    % logFileName = sprintf(log_str, ...
                    %                       subId,...
                    %                       runNumber);
                    % logFilePath = fullfile(EVFile.folder, logFileName)

                    % transform the scan to MNI space
                    if ~exist(fullfile(featDir,'filtered_func_data_MNI.nii.gz'),'file') || params.override
                        tranformFeatDirToMNI(featDir)
                    else
                        fprintf('MNI transform for sub condition already exists\n')
                    end

                    % calculate percent-signal-change
                    functionalDataPath = fullfile(featDir,'filtered_func_data_MNI.nii.gz');
                    functionalData = niftiread(functionalDataPath);
                    metadata = niftiinfo(functionalDataPath);
                    pscMatrix = calcPercentSignalChange(functionalData);

                    % Get the trial start times.
                    EVFilePath = fullfile(EVFile.folder, EVFile.name)
                    temp = load(EVFilePath);
                    startTimes = round(str2double(temp.newT{:,1}));
                    for i = 1:length(startTimes)
                        startTime = startTimes(i);
                        endTime = startTime + trialLength;

                        % Get the average of the activation along the trial
                        % trialData = pscMatrix(:, :, :, startTime:endTime);
                        % meanTrialData = mean(trialData, 4);

                        % Sample the trial's data where we found it's most likely to peak
                        trialPeakData = pscMatrix(:, :, :, startTime + peakActivationTime);
                        condition = sprintf("%s_%s", ear, hand);
                        switch condition
                          case 'LE_LH'
                            data_LE_LH = cat(4, data_LE_LH, trialPeakData);
                            labels_LE_LH(i) = 1;
                          case 'LE_RH'
                            data_LE_RH = cat(4, data_LE_RH, trialPeakData);
                            labels_LE_RH(i) = 2;
                          case 'RE_LH'
                            data_RE_LH = cat(4, data_RE_LH, trialPeakData);
                            labels_RE_LH(i) = 3;
                          case 'RE_RH'
                            data_RE_RH = cat(4, data_RE_RH, trialPeakData);
                            labels_RE_RH(i) = 4;
                        end %switch


                    end % for start times
                end % for EVFile
            end % for ear
        end % for hand

                        %% There maybe an unequal number of trials in each group (due to disqualified trials)
                        %% Note: truncate from the end - better to randomize
                    allLabels = [labels_LE_LH; labels_LE_RH; labels_RE_LH; labels_RE_RH;]
                    [t, minTrials_t] = find(allLabels == 0, 2);
                    if (exist("minTrials_t", 'var'))
                        minTrials = min(minTrials_t);
                        data_LE_LH = data_LE_LH(:,:,:,1:minTrials);
                        data_LE_RH = data_LE_RH(:,:,:,1:minTrials);
                        data_RE_LH = data_RE_LH(:,:,:,1:minTrials);
                        data_RE_RH = data_RE_RH(:,:,:,1:minTrials);
                    end

                data_all_LE = cat(4, data_LE_LH, data_LE_RH);
                data_all_RE = cat(4, data_RE_LH, data_RE_RH);
                labels_all_LE = cat(4, labels_LE_LH, labels_LE_RH);
                labels_all_RE = cat(4, labels_RE_LH, labels_RE_RH);

                % Write to file
                % save(fullfile(outDir,['pc_native' fname]),'pc_funcData','funcInfo','-v7.3')
                niftiwrite(pscMatrix,fullfile(params.multiTOutDir, sprintf("%d_PercentSignalChange_%s_%s", subId, ear, hand)), metadata, 'Compressed',true)
                save(fullfile(params.multiTOutDir, ...
                              sprintf("%d_multiT_data_and_labels", subId)), ...
                     'labels_LE_LH', ...
                     'labels_LE_RH', ...
                     'labels_RE_LH', ...
                     'labels_RE_RH', ...
                     'data_LE_LH', ...
                     'data_LE_RH', ...
                     'data_RE_LH', ...
                     'data_RE_RH', ...
                     'data_all_LE', ...
                     'data_all_RE', ...
                     'labels_all_LE', ...
                     'labels_all_RE', ...
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
