function createMVPAData(params)
    if ~exist(params.outDir)
        mkdir(params.outDir)
    end
    rng(params.seed);

    %% load mask and split to beams
    % maskImg.data=niftiread(fullfile(params.mask.dir,params.mask.name));
    maskImg.data=niftiread(params.mask.path);
    % maskImg.info=niftiinfo(fullfile(params.mask.dir,params.mask.name));
    linearIndex=find(maskImg.data);
    [x,y,z]=ind2sub(size(maskImg.data),linearIndex);
    locations=[x,y,z];
    beamMembersIdx = knnsearch(locations, locations, 'K', params.beamSize); % Find all neighbours in the mask

    %% load data for each condition and create svm files
    % base_str = "%d_EV_audiomotor_%d_%sE_%sH.txt";
    base_str = "%d_EV_audiomotor_*_%sE_%sH.txt";
    log_str = "%d_audiomotor_%d_log.mat";
    ears = ['L', 'R'];
    for ear = ears
        % only compute this for experimental runs
        numRuns = params.numRunsPerCondition(params.conditions == "audiomotor")

        for subId=params.subjects
            functionalDir = sprintf(params.functionalDir, subId);
            hands = ["L", "R"];
            for hand = hands
                % for runNumber = 1:numRuns
                EVDir = sprintf(params.EVDir, subId);
                EVFilename = sprintf(base_str, ...
                                     subId,...
                                     ear,...
                                     hand);
                % find all files with this ear-hand combination
                files = dir(fullfile(EVDir,EVFilename));

                % check if this runNum really had auditory input to this ear
                % should never happen
                assert(length(files) ~= 0)

                if length(files) == 0
                    continue
                end

                for fileId = 1:length(files)
                    file = files(fileId)
                    x = file.name;
                    t = strsplit(x, '_');
                    runNumber = str2double(t{4});
                    featDir = fullfile(functionalDir, ...
                                       sprintf("sub%d_audiomotor_%d_%sE.feat", ...
                                               subId, ...
                                               runNumber, ...
                                               ear));
                    logFileName = sprintf(log_str, ...
                                          subId,...
                                          runNumber);

                    logFilePath = fullfile(file.folder, logFileName)

                    % transform the scan to MNI space
                    if ~exist(fullfile(featDir,'filtered_func_data_MNI.nii.gz'),'file') || params.override
                        tranformFeatDirToMNI(featDir)
                    else
                        fprintf('MNI transform for sub condition already exists\n')
                    end

                    % calculate percent-signal-change
                    functionalData = calcPercentSignalChange(featDir);

                    %get TRs where we sample the data
                    temp = load(logFilePath);
                    log = temp.log;
                    TRs = log.blockEndTimes(1:end-1); % last block is a mock-block
                    tempData = zeros(length(TRs), length(linearIndex));

                    % for each timepoint take the 3D brain func data
                    % at that point, and serialize it. keep them all in
                    % conditionData
                    for TRi = 1:length(TRs)
                        t = functionalData(:,:,:,TRi);
                        tempData(TRi, :) = t(linearIndex);
                    end

                    condData(: ,:, runNumber) = tempData;
                end % for file
                    % end % for runNumber


                % concatenate all rows into a column vector.
                % each row is the linear data from a single run of this
                % condition
                allData.(hand) = reshape(condData,[], size(condData, 2));
            end % for hand

            % equalize sample number between hands
            RHSamples = size(allData.R,1);
            LHSamples = size(allData.L,1);
            numToTrim = abs(RHSamples - LHSamples);
            removeIdx = datasample(1:min(RHSamples, ...
                                         LHSamples), ...
                                   numToTrim, ...
                                   'Replace', ...
                                   false);
            mask = ones(1, max(RHSamples, LHSamples));
            mask(removeIdx) = 0;
            if RHSamples > LHSamples
                allData.R = allData.R(mask > 0,:);
                RHSamples = size(allData.R,1);
            elseif RHSamples < LHSamples
                allData.L= allData.L(mask > 0,:);
                LHSamples = size(allData.L,1);
            end

            % construct labels and factor
            tempData=[allData.R; allData.L];

            % 1 = RH; 2 = LH
            labels=[ones(RHSamples,1);ones(LHSamples,1) * 2];
            factor=ones(1,length(labels));

            % construct the final data matrix
            data=zeros(length(labels), params.beamSize, length(linearIndex));
            for centralVoxelIdx=1:length(linearIndex)
                data(:,:,centralVoxelIdx) = ...
                    tempData(:,beamMembersIdx(centralVoxelIdx,:));
            end

            % write to file
            save(fullfile(params.outDir, ...
                          sprintf("%d_MPVA_audiomotor_%sE", subId, ear)), ...
                 'data', ...
                 'factor', ...
                 'labels', ...
                 'locations', ...
                 'linearIndex', ...
                 'params', ...
                 'maskImg', ...
                 '-v7.3');
        end % for subId
    end % for ear
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

    % disp(['finished MNI transform for sub ', ...
    %       num2str(subId), ...
    %       ' ', ...
    %       cond, ...
    %       ' condition run ', ...
    %       num2str(r)]);
end

function percentChangeData=calcPercentSignalChange(featDir)
    functionalData = niftiread(fullfile(featDir,'filtered_func_data_MNI.nii.gz'));
    percentChangeData=functionalData./mean(functionalData,4)*100-100;
end
