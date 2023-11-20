function computeMeanTimeCourseAuditory()
    params = setAnalysisParams();
    if ~exist(params.timeCourseOutDir)
        mkdir(params.timeCourseOutDir)
    end
    rng(params.seed);

    % Get file names
    filePattern = fullfile(params.timeCourseOutDir, '*_time_course_auditory.mat');
    theFiles = dir(filePattern);

    % Initialize 3D arrays
    all_LE_LCortex = [];
    all_LE_RCortex = [];
    all_RE_LCortex = [];
    all_RE_RCortex = [];

    % Iterate over files and store data
    for k = 1:length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, baseFileName);

        % Load the data from .m files
        load(fullFileName);

        % Store data in 3D arrays
        all_LE_LCortex (:,:,k) = LE_LCortex;
        all_LE_RCortex (:,:,k) = LE_RCortex;
        all_RE_LCortex (:,:,k) = RE_LCortex;
        all_RE_RCortex (:,:,k) = RE_RCortex;
    end

    % Compute mean across the third dimension (subjects)
    average_LE_LCortex = mean(LE_LCortex, 3);
    average_LE_RCortex = mean(LE_RCortex, 3);
    average_RE_LCortex = mean(RE_LCortex, 3);
    average_RE_RCortex = mean(RE_RCortex, 3);

    range = [6:10]; % Time in seconds to average across - peak activation time
    % Compute per-subjct mean across the scond dimension (time)
    subject_mean_LE_LCortex = squeeze(mean(all_LE_LCortex(1, range, :), 2))';
    subject_mean_LE_RCortex = squeeze(mean(all_LE_RCortex(1, range, :), 2))';
    subject_mean_RE_LCortex = squeeze(mean(all_RE_LCortex(1, range, :), 2))';
    subject_mean_RE_RCortex = squeeze(mean(all_RE_RCortex(1, range, :), 2))';
    [bIsSignificant_LCortex, p_LCortex] = ttest(subject_mean_LE_LCortex, subject_mean_RE_LCortex);
    [bIsSignificant_RCortex, p_RCortex] = ttest(subject_mean_LE_RCortex, subject_mean_RE_RCortex);

    % Save averaged data to a new .mat file
    save(fullfile(params.timeCourseOutDir,  'time_course_auditory_mean.mat'), ...
         'average_LE_LCortex', ...
         'average_LE_RCortex', ...
         'average_RE_LCortex', ...
         'average_RE_RCortex', ...
         'subject_mean_LE_LCortex', ...
         'subject_mean_LE_RCortex', ...
         'subject_mean_RE_LCortex', ...
         'subject_mean_RE_RCortex', ...
         'bIsSignificant_LCortex', ...
         'p_LCortex', ...
         'bIsSignificant_RCortex', ...
         'p_RCortex', ...
         '-v7.3');
end
