function createAuditoryPSC()
    params = setAnalysisParams();
    for S = 1:length(params.subjects)
        subId = params.subjects(S)
        functionalDir = sprintf(params.functionalDir, subId);
        % Initialization - here because of parallel computing
        pscMatrix = [];
        for runNumber = [1:2]
            featDir = fullfile(functionalDir, ...
                               sprintf("sub%d_auditoryLoc_%d.feat", ...
                                       subId, ...
                                       runNumber));
            pscFileName = fullfile(params.multiTOutDirAuditory, sprintf("%d_PercentSignalChange_%d_auditoryLoc", subId, runNumber));
            if ~exist(strcat(pscFileName, ".nii.gz"), 'file') || params.override
                functionalDir = sprintf(params.functionalDir, subId);
                featDir = fullfile(functionalDir, ...
                                   sprintf("sub%d_auditoryLoc_%d.feat", ...
                                           subId, ...
                                           runNumber));

                % Do we need to regenerate the warped image?
                if ~exist(fullfile(featDir,'filtered_func_data_MNI.nii.gz'),'file') || params.override
                    tranformFeatDirToMNI(featDir)
                else
                    fprintf('MNI transform for subject %d run no. %d already exists\n', subId, runNumber)
                end

                % Calculate the actual matrix
                functionalDataPath = fullfile(featDir,'filtered_func_data_MNI.nii.gz');
                fprintf("reading from %d, run %d\n", subId, runNumber)
                functionalData = niftiread(functionalDataPath);
                metadata = niftiinfo(functionalDataPath);
                fprintf("calculating PSC matrix")
                pscMatrix = single(calcPercentSignalChange(functionalData));
                fprintf("writing PSC matrix to file")
                niftiwrite(pscMatrix, pscFileName, metadata, 'Compressed',true);
            else
                fprintf('PSC matrix for subject %d run no. %d already exists\n', subId, runNumber)
            end

        end
    end
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
