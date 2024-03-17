function getTtestTabelsMotor()
params = setAnalysisParams();
assert(exist(params.timeCourseOutDir))

% Get file names
dataFile = fullfile(params.timeCourseOutDir, 'time_course_motor_mean.mat');
load(dataFile)

[bIsSignificant_LCortex, p_LCortex, ci_LCortex, stats_LCortex] = ttest(subject_mean_LH_LCortex, subject_mean_RH_LCortex);
[bIsSignificant_RCortex, p_RCortex, ci_RCortex, stats_RCortex] = ttest(subject_mean_LH_RCortex, subject_mean_RH_RCortex);

% Assuming you have already run the t-tests and obtained the necessary variables

% Extracting data for the Left Cortex
LCortex_tstat = stats_LCortex.tstat;
LCortex_pvalue = p_LCortex;
LCortex_RH_mean = mean(subject_mean_RH_LCortex);
LCortex_LH_mean = mean(subject_mean_LH_LCortex);
LCortex_RH_std = std(subject_mean_RH_LCortex);
LCortex_LH_std = std(subject_mean_LH_LCortex);

% Extracting data for the Right Cortex
RCortex_tstat = stats_RCortex.tstat;
RCortex_pvalue = p_RCortex;
RCortex_RH_mean = mean(subject_mean_RH_RCortex);
RCortex_LH_mean = mean(subject_mean_LH_RCortex);
RCortex_RH_std = std(subject_mean_RH_RCortex);
RCortex_LH_std = std(subject_mean_LH_RCortex);

% Create a table for both cortices
LCortex_Table = table(LCortex_tstat, LCortex_pvalue, LCortex_RH_mean, LCortex_LH_mean, LCortex_RH_std, LCortex_LH_std, ...
    'VariableNames', {'t-statistic', 'p-value', 'RH mean', 'LH mean', 'RH std', 'LH std'});

RCortex_Table = table(RCortex_tstat, RCortex_pvalue, RCortex_RH_mean, RCortex_LH_mean, RCortex_RH_std, RCortex_LH_std, ...
    'VariableNames', {'t-statistic', 'p-value', 'RH mean', 'LH mean', 'RH std', 'LH std'});

% Displaying the tables
disp('Left Cortex Table:');
disp(LCortex_Table);

disp('Right Cortex Table:');
disp(RCortex_Table);
