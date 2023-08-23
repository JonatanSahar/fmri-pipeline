function pscMatrix = niiToPSC(niiFilePath)
    % Load the NIfTI file
    niiData = niftiread(niiFilePath);

    % Calculate the mean signal for each voxel across time
    baselineSignal = mean(niiData, 4);

    % Replicate the baseline signal to match the 4D size of niiData
    baselineReplicated = repmat(baselineSignal, [1, 1, 1, size(niiData, 4)]);

    % Avoid division by zero: Set a small value to baseline voxels that are zero
    baselineReplicated(baselineReplicated == 0) = eps;

    % Calculate the percent signal change
    pscMatrix = ((niiData - baselineReplicated) ./ baselineReplicated) * 100;
end
