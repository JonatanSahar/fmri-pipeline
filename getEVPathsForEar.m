function EVPaths = getEVPathsForEar(params, ear)
%% load data for each condition and create svm files
    base_str = "%d_EV_audiomotor_%d_%sE_%sH.txt";
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
            for condRunNum = 1:numRuns
                featDir = fullfile(functionalDir, sprintf("sub%d_audiomotor_%d_%sE.feat", subId, condRunNum, ear));
                hands = ["L", "R"];
                for hand = hands
                    EV_filename = sprintf(str,...
                                          subId,...
                                          condRunNum,...
                                          ear,...
                                          hand);
                    EVDir = sprintf(params.EVDir, subId);
                    d = dir(fullfile(EVDir,EV_filename));
                    EVPath = fullfile(d.folder, d.name);
                    EVPaths.(side) = EVPath;
                end % for hand
            end % for condRunNum
        end % for subId
    end % for condId
end
