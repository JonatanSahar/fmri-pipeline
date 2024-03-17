function getTtestTabels()
params = setAnalysisParams();
assert(exist(params.timeCourseOutDir))

% Get file names
dataFile = fullfile(params.timeCourseOutDir, 'time_course_mean.mat');
load(dataFile)

% Assuming you have already run the t-tests and obtained the necessary variables

% Extracting data for the Left Cortex - Option 1
LCortex_tstat_LE = stats_LCortex.tstat;
LCortex_pvalue_LE = p_LCortex;
LCortex_RH_mean_LE = mean(subject_mean_LE_LCortex_RH);
LCortex_LH_mean_LE = mean(subject_mean_LE_LCortex_LH);
LCortex_RH_std_LE = std(subject_mean_LE_LCortex_RH);
LCortex_LH_std_LE = std(subject_mean_LE_LCortex_LH);

% Extracting data for the Left Cortex - Option 2
LCortex_tstat_RE = stats_LCortex.tstat;
LCortex_pvalue_RE = p_LCortex;
LCortex_RH_mean_RE = mean(subject_mean_RE_LCortex_RH);
LCortex_LH_mean_RE = mean(subject_mean_RE_LCortex_LH);
LCortex_RH_std_RE = std(subject_mean_RE_LCortex_RH);
LCortex_LH_std_RE = std(subject_mean_RE_LCortex_LH);

% Extracting data for the Right Cortex - Option 1
RCortex_tstat_LE = stats_RCortex.tstat;
RCortex_pvalue_LE = p_RCortex;
RCortex_RH_mean_LE = mean(subject_mean_LE_RCortex_RH);
RCortex_LH_mean_LE = mean(subject_mean_LE_RCortex_LH);
RCortex_RH_std_LE = std(subject_mean_LE_RCortex_RH);
RCortex_LH_std_LE = std(subject_mean_LE_RCortex_LH);

% Extracting data for the Right Cortex - Option 2
RCortex_tstat_RE = stats_RCortex.tstat;
RCortex_pvalue_RE = p_RCortex;
RCortex_RH_mean_RE = mean(subject_mean_RE_RCortex_RH);
RCortex_LH_mean_RE = mean(subject_mean_RE_RCortex_LH);
RCortex_RH_std_RE = std(subject_mean_RE_RCortex_RH);
RCortex_LH_std_RE = std(subject_mean_RE_RCortex_LH);

% Create tables for both cortices and options
LCortex_Table = table([LCortex_tstat_LE; LCortex_tstat_RE], [LCortex_pvalue_LE; LCortex_pvalue_RE], ...
    [LCortex_RH_mean_LE; LCortex_RH_mean_RE], [LCortex_LH_mean_LE; LCortex_LH_mean_RE], ...
    [LCortex_RH_std_LE; LCortex_RH_std_RE], [LCortex_LH_std_LE; LCortex_LH_std_RE], ...
    'VariableNames', {'t-statistic', 'p-value', 'RH mean', 'LH mean', 'RH std', 'LH std'}, ...
    'RowNames', {'LE', 'RE'});

RCortex_Table = table([RCortex_tstat_LE; RCortex_tstat_RE], [RCortex_pvalue_LE; RCortex_pvalue_RE], ...
    [RCortex_RH_mean_LE; RCortex_RH_mean_RE], [RCortex_LH_mean_LE; RCortex_LH_mean_RE], ...
    [RCortex_RH_std_LE; RCortex_RH_std_RE], [RCortex_LH_std_LE; RCortex_LH_std_RE], ...
    'VariableNames', {'t-statistic', 'p-value', 'RH mean', 'LH mean', 'RH std', 'LH std'}, ...
    'RowNames', {'LE', 'RE'});

% Displaying the tables
disp('Left Cortex Table:');
disp(LCortex_Table);

disp('Right Cortex Table:');
disp(RCortex_Table);
