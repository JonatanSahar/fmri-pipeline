function calculateANOVAMotor()
    params = setAnalysisParams();
    nsubs = numel(params.subjects)
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_motor_mean.mat"));
    anova_data_both = [data.subject_mean_LH_LCortex', data.subject_mean_RH_LCortex', data.subject_mean_LH_RCortex', data.subject_mean_RH_RCortex']

    WithinDesign = table({'LCortex', 'LCortex', 'RCortex', 'RCortex'}', {'LH', 'RH', 'LH', 'RH'}', ...
                         'VariableNames', {'Cortex', 'Hand'});

    tblBoth = array2table(anova_data_both, 'VariableNames', {'LCortex_LH', 'LCortex_RH', 'RCortex_LH', 'RCortex_RH'});

    rm = fitrm(tblBoth, 'LCortex_LH-RCortex_RH ~ 1', 'WithinDesign', WithinDesign);
    ranovatbl_both = ranova(rm, 'WithinModel','Cortex*Hand');
    disp(ranovatbl_both)


    % post hoc t-tests
    [bIsSignificant_LCortex, p_LCortex] = ttest(data.subject_mean_LH_LCortex, data.subject_mean_RH_LCortex);
    [bIsSignificant_RCortex, p_RCortex] = ttest(data.subject_mean_LH_RCortex, data.subject_mean_RH_RCortex);

    results = table(['LCortex'; 'RCortex'], ...
                    [bIsSignificant_LCortex; bIsSignificant_RCortex], ...
                    [p_LCortex; p_RCortex], ...
                    'VariableNames', {'Condition', 'IsSignificant', 'pValue'});

    % Display the table
    disp("Post hoc analysis comparing hands per cortex")
    disp(results);

    % Create a table with M and SD per group
    results = table(['LCortex_LE_LH'; 'LCortex_LE_RH'; 'RCortex_LE_LH'; 'RCortex_LE_RH'; 'LCortex_RE_LH'; 'LCortex_RE_RH'; 'RCortex_RE_LH'; 'RCortex_RE_RH'], ...
                    [mean(data.subject_mean_LH_LCortex); mean(data.subject_mean_RH_LCortex); mean(data.subject_mean_LH_RCortex); mean(data.subject_mean_RH_RCortex)], ...
                    [std(data.subject_std_LH_LCortex); std(data.subject_std_RH_LCortex); std(data.subject_std_LH_RCortex); std(data.subject_std_RH_RCortex)], ...
                    'VariableNames', {'Condition', 'mean', 'std'});

    % Display the table
    disp("Post hoc analysis comparing hands per ear, per cortex")
    disp(results);
end
