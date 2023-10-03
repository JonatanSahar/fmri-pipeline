function computeMeanTimeCourseDifference()
    params = setAnalysisParams();
    if ~exist(params.timeCourseOutDir)
        mkdir(params.timeCourseOutDir)
    end

    % Get file names
    filePattern = fullfile(params.timeCourseOutDir, '*_time_course.mat');
    theFiles = dir(filePattern);

    % Initialize 3D arrays
    all_LE_LCortex_LH = [];
    all_LE_LCortex_RH = [];
    all_LE_RCortex_LH = [];
    all_LE_RCortex_RH = [];
    all_RE_LCortex_LH = [];
    all_RE_LCortex_RH = [];
    all_RE_RCortex_LH = [];
    all_RE_RCortex_RH = [];

    % Iterate over files and store data
    for k = 1:length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, baseFileName);

        % Load the data from .mat files
        load(fullFileName);

        % Store data in 3D arrays
        all_LE_LCortex_LH(k, :) = LE_LCortex_LH(6:10);
        all_LE_LCortex_RH(k, :) = LE_LCortex_RH(6:10);
        all_LE_RCortex_LH(k, :) = LE_RCortex_LH(6:10);
        all_LE_RCortex_RH(k, :) = LE_RCortex_RH(6:10);
        all_RE_LCortex_LH(k, :) = RE_LCortex_LH(6:10);
        all_RE_LCortex_RH(k, :) = RE_LCortex_RH(6:10);
        all_RE_RCortex_LH(k, :) = RE_RCortex_LH(6:10);
        all_RE_RCortex_RH(k, :) = RE_RCortex_RH(6:10);
    end
    size(all_RE_RCortex_LH)
    % Take the point-by-point difference between the LH and RH trials means per subject, then compute the mean across the 2nd dimension (time). We get a number per subject representing the mean difference between RH and LH activation in each condition.
    diff_LE_LCortex = mean(all_LE_LCortex_LH - all_LE_LCortex_RH, 2);
    diff_LE_RCortex = mean(all_LE_RCortex_LH - all_LE_RCortex_RH, 2);
    diff_RE_LCortex = mean(all_RE_LCortex_LH - all_RE_LCortex_RH, 2);
    diff_RE_RCortex = mean(all_RE_RCortex_LH - all_RE_RCortex_RH, 2);

    % Perform a t-test on each group of differences, i.e. per cortex per ear
    [h_LE_LCortex,  pval_LE_LCortex] = ttest(diff_LE_LCortex);
    [h_LE_RCortex,  pval_LE_RCortex] = ttest(diff_LE_RCortex);
    [h_RE_LCortex,  pval_RE_LCortex] = ttest(diff_RE_LCortex);
    [h_RE_RCortex,  pval_RE_RCortex] = ttest(diff_RE_RCortex);
    info  = "Take the point-by-point difference between the LH and RH trials means per subject (given by computeMeanTimeCourse), then compute the mean across time. We get a number per subject representing the mean difference between RH and LH activation in each condition. We then run a t-test on the groups of differences"
% Create a table with the data
ttest_results = table({'LE_LCortex'; 'LE_RCortex'; 'RE_LCortex'; 'RE_RCortex'}, ...
                      [h_LE_LCortex; h_LE_RCortex; h_RE_LCortex; h_RE_RCortex], ...
                      [pval_LE_LCortex; pval_LE_RCortex; pval_RE_LCortex; pval_RE_RCortex], ...
                      'VariableNames', {'Region', 'TTest_Hypothesis', 'P_Value'})

    % Save averaged data to a new .mat file
    save(fullfile(params.timeCourseOutDir,  'time_course_ttest.mat'), "h_LE_RCortex",  "pval_LE_RCortex", "h_RE_LCortex",  "pval_RE_LCortex", "h_LE_LCortex",  "pval_LE_LCortex", "h_RE_RCortex",  "pval_RE_RCortex",  "diff_LE_RCortex", "diff_RE_LCortex", "diff_LE_LCortex", "diff_RE_RCortex", "ttest_results", "info", '-v7.3');
end
