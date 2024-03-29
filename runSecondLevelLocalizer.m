function runSecondLevelLocalizer(params, subId, condition, numRuns)
        templateFile = sprintf('secondLevelTemplate_%d_runs.fsf', numRuns);
        templatePath = fullfile(params.fsfdir, templateFile);
        % Collect the paths of the .feat dirs for all runs of that condition
        featDirPattern = fullfile(params.experimentDir, ...
                                  num2str(subId), 'functional', ...
                                  sprintf('sub%d_%s_*.feat', subId, condition));
        featDirs = dir(featDirPattern);
        featPaths = fullfile({featDirs.folder}, {featDirs.name});

        % Generate name and path for mean gfeat dir
        meanGfeatDir = sprintf('%d_%s_mean', subId, condition);
        meanGfeatPath = fullfile(params.experimentDir, num2str(subId), 'functional', meanGfeatDir);

        % Replace the paths into the .fsf template for each run
        fsfText = fileread(templatePath);
        for r = 1:numRuns
            runFeatPath = fullfile(featDirs(r).folder, featDirs(r).name);
            runStr = sprintf('run_%d_dir', r);
            fsfText = strrep(fsfText, runStr, runFeatPath);
        end

    fsfText = strrep(fsfText, 'output_dir', meanGfeatPath);

    % Write the modified .fsf file to disk
    outputFsfFile = fullfile(params.fsfdir, sprintf('%s.fsf', meanGfeatDir));
    fid = fopen(outputFsfFile, 'w');
    fwrite(fid, fsfText);
    fclose(fid);

    % Call feat with the modified .fsf file
    % system(sprintf('feat %s', outputFsfFile));
    fprintf('feat %s&\n', outputFsfFile);

end
