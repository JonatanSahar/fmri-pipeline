function createAuditoryPSC()
    params = setAnalysisParams();
    for S = 1:length(params.subjects)
        subId = params.subjects(S)
        % Initialization - here because of parallel computing
        pscMatrix = [];
        for runNumber = [1:2]
            pscFileName = fullfile(params.multiTOutDir, sprintf("%d_PercentSignalChange_%d_auditoryLoc.nii.gz", subId, runNumber));
            if exist(pscFileName, 'file') && ~params.override
                continue
            end
            functionalDir = sprintf(params.functionalDir, subId);
            featDir = fullfile(functionalDir, ...
                               sprintf("sub%d_auditoryLoc_%d.feat", ...
                                       subId, ...
                                       runNumber));
            if ~exist(fullfile(featDir,'filtered_func_data_MNI.nii.gz'),'file') || params.override
                tranformFeatDirToMNI(featDir)
            else
                fprintf('MNI transform for subject %d run no. %d already exists\n', subId, runNumber)
            end
            functionalDataPath = fullfile(featDir,'filtered_func_data_MNI.nii.gz');
            fprintf("reading from %d, run %d\n", subId, runNumber)
            functionalData = niftiread(functionalDataPath);
            metadata = niftiinfo(functionalDataPath);
            fprintf("calculating PSC matrix")
            pscMatrix = calcPercentSignalChange(functionalData);
            fprintf("writing PSC matrix to file")
            niftiwrite(pscMatrix, pscFileName, metadata, 'Compressed',true);
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
