function createMVPAparams(Data)
    if ~exist(params.outDir)
        mkdir(params.outDir)
    end
    rng(params.seed);

    %% load mask and split to beams
    maskImg.data=niftiread(fullfile(params.mask.dir,params.mask.name));
    maskImg.info=niftiinfo(fullfile(params.mask.dir,params.mask.name));
    linearIndex=find(maskImg.data);
    [x,y,z]=ind2sub(size(maskImg.data),linearIndex);
    locations=[x,y,z];
    idx = knnsearch(locations, locations, 'K', params.beamSize); % Find all neighbours in the mask

    %% load data for each condition and create svm files
    base_str = "%d_EV_audiomotor_%d_%sE_%sH.txt";
    log_str = "%d_audiomotor_%d_%sE_%sH.txt";
    ears = [L, R];
    for ear = ears
        for condId = 1:length(params.conditions)
            cond = params.conditions(condId);
            numRuns = params.numRunsPerCondition(condId);
            if ~contains(cond, 'audiomotor')
                continue
            end

            for subId=params.subjects
                functionalDir = sprintf(params.functionalDir, subId);
                anatomyDir = sprintf(params.anatomyDir, subId);
                % sub102_audiomotor_1_RE.feat
                hands = ["L", "R"];
                for hand = hands
                    for condRunNum = 1:numRuns
                        featDir = fullfile(functionalDir, sprintf("sub%d_audiomotor_%d_%sE.feat", subId, condRunNum, ear));
                        EV_filename = sprintf(str,...
                                              subId,...
                                              condRunNum,...
                                              ear,...
                                              hand);
                        EVDir = sprintf(params.EVDir, subId);
                        d = dir(fullfile(EVDir,EV_filename));
                        % this runNum really had auditory input to this ear
                        if d.name
                            EVPath = fullfile(d.folder, d.name);
                            logFileName = sprintf(log_str, ...
                                                  subId,...
                                                  condRunNum,...
                                                  ear,...
                                                  hand);
                            logFilePath = fullfile(EVDir, logFileName);

                            EVPaths.(side) = EVPath;
                            logFilePaths.(side) = logFilePath;
                        end

                        % transform the scan to MNI space
                        tranformFeatDirToMNI(featDir)
                        % calculate percent-signal-change
                        funcData=niftiread(fullfile(runDir,'filtered_func_data_MNI.nii.gz'));
                        percentChangeData=funcData./mean(funcData,4)*100-100;
                        log =
                    end % for hand
                end % for condRunNum
            end % for subId
        end % for condId
    end % for ear
end


function tranformFeatDirToMNI(featDir)
    if ~exist(fullfile(featDir,'filtered_func_data_MNI.nii.gz'),'file') ...
            ||params.override
        cmd = ['applywarp -i ', ...
               (fullfile(featDir, 'filtered_func_data.nii.gz')), ...
               ' -o ', ...
               (fullfile(featDir, 'filtered_func_data_MNI.nii.gz')), ...
               ' -r ', ...
               fullfile(featDir, 'reg', 'standard'), ...
               ' --warp=' , ...
               fullfile(featDir, 'reg', 'highres2standard_warp'), ...
               ' --premat=', ...
               fullfile(featDir, 'reg', 'example_func2highres.mat')];
        unix(cmd);
        disp(['finished MNI transform for sub ', ...
              num2str(subId), ...
              ' ', ...
              cond, ...
              ' condition run ', ...
              num2str(r)]);
    else
        disp(['MNI transform for sub ', ...
              num2str(params.subjects(s)), ...
              ' ', ...
              cond, ...
              ' condition run ', ...
              num2str(condRunNum), ...
              ' already exist']);
    end
end
