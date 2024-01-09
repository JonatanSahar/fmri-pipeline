function calculateANOVA()
    params = setAnalysisParams();
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_mean.mat"));
    anova_data_LCortext = [data.subject_mean_LE_LCortex_LH', data.subject_mean_LE_LCortex_RH', data.subject_mean_RE_LCortex_LH', data.subject_mean_RE_LCortex_RH'];
    anova_data_RCortext = [data.subject_mean_LE_RCortex_LH', data.subject_mean_LE_RCortex_RH', data.subject_mean_RE_RCortex_LH', data.subject_mean_RE_RCortex_RH']

    WithinDesign = table({'LE', 'LE', 'RE', 'RE'}', {'LH', 'RH', 'LH', 'RH'}', ...
                         'VariableNames', {'Ear', 'Hand'});

    tblLCortex = array2table(anova_data_LCortext, 'VariableNames', {'LE_LH', 'LE_RH', 'RE_LH', 'RE_RH'});
    tblRCortex = array2table(anova_data_RCortext, 'VariableNames', {'LE_LH', 'LE_RH', 'RE_LH', 'RE_RH'});

    rm = fitrm(tblLCortex, 'LE_LH-RE_RH ~ 1', 'WithinDesign', WithinDesign);
    ranovatbl_LCortex = ranova(rm, 'WithinModel','Ear*Hand');
    disp("Left Cortex ANOVA")
    disp(ranovatbl_LCortex)

    rm = fitrm(tblRCortex, 'LE_LH-RE_RH ~ 1', 'WithinDesign', WithinDesign);
    ranovatbl_RCortex = ranova(rm, 'WithinModel','Ear*Hand');
    disp("Right Cortex ANOVA")
    disp(ranovatbl_RCortex)

    % post hoc t-tests
    [bIsSignificant_LCortex_LE, p_LCortex_LE] = ttest(data.subject_mean_LE_LCortex_LH, data.subject_mean_LE_LCortex_RH);
    [bIsSignificant_LCortex_RE, p_LCortex_RE] = ttest(data.subject_mean_RE_LCortex_LH, data.subject_mean_RE_LCortex_RH);
    [bIsSignificant_RCortex_LE, p_RCortex_LE] = ttest(data.subject_mean_LE_RCortex_LH, data.subject_mean_LE_RCortex_RH);
    [bIsSignificant_RCortex_RE, p_RCortex_RE] = ttest(data.subject_mean_RE_RCortex_LH, data.subject_mean_RE_RCortex_RH);




    % Create a table with the results
    results = table(['LCortex_LE'; 'LCortex_RE'; 'RCortex_LE'; 'RCortex_RE'], ...
                    [bIsSignificant_LCortex_LE; bIsSignificant_LCortex_RE; bIsSignificant_RCortex_LE; bIsSignificant_RCortex_RE], ...
                    [p_LCortex_LE; p_LCortex_RE; p_RCortex_LE; p_RCortex_RE], ...
                    'VariableNames', {'Condition', 'IsSignificant', 'pValue'});

    % Display the table
    disp("Post hoc analysis comparing hands per ear, per cortex")
    disp(results);

    % Create a table with M and SD per group
    results = table(['LCortex_LE_LH'; 'LCortex_LE_RH'; 'RCortex_LE_LH'; 'RCortex_LE_RH'; 'LCortex_RE_LH'; 'LCortex_RE_RH'; 'RCortex_RE_LH'; 'RCortex_RE_RH'], ...
                    [mean(data.subject_mean_LE_LCortex_LH); mean(data.subject_mean_RE_LCortex_LH); mean(data.subject_mean_LE_RCortex_LH); mean(data.subject_mean_RE_RCortex_LH); mean(data.subject_mean_LE_LCortex_RH); mean(data.subject_mean_RE_LCortex_RH); mean(data.subject_mean_LE_RCortex_RH); mean(data.subject_mean_RE_RCortex_RH)],...
                    [std(data.subject_mean_LE_LCortex_LH); std(data.subject_mean_RE_LCortex_LH); std(data.subject_mean_LE_RCortex_LH); std(data.subject_mean_RE_RCortex_LH); std(data.subject_mean_LE_LCortex_RH); std(data.subject_mean_RE_LCortex_RH); std(data.subject_mean_LE_RCortex_RH); std(data.subject_mean_RE_RCortex_RH)]
                    'VariableNames', {'Condition', 'mean', 'std'});

    % Display the table
    disp("Post hoc analysis comparing hands per ear, per cortex")
    disp(results);
    % calculete means for effect size calculation
    % data_LCortext_LE = [data.subject_mean_LE_LCortex_LH'; data.subject_mean_LE_LCortex_RH'];
    % data_LCortext_RE = [data.subject_mean_RE_LCortex_LH'; data.subject_mean_RE_LCortex_RH'];
    % data_RCortext_LE = [data.subject_mean_LE_RCortex_LH'; data.subject_mean_LE_RCortex_RH'];
    % data_RCortext_RE = [data.subject_mean_RE_RCortex_LH'; data.subject_mean_RE_RCortex_RH'];
    % meanLCortext_LE = mean(data_LCortext_LE);
    % meanLCortext_RE = mean(data_LCortext_RE);
    % meanRCortext_LE = mean(data_RCortext_LE);
    % meanRCortext_RE = mean(data_RCortext_RE);

    results = table(['RE_LCortex_LH'; 'RE_LCortex_RH'; 'LE_LCortex_LH'; 'LE_LCortex_RH'; 'RE_RCortex_LH'; 'RE_RCortex_RH'; 'LE_RCortex_LH'; 'LE_RCortex_RH'], ...
[mean(data.subject_mean_RE_LCortex_LH); ...
mean(data.subject_mean_RE_LCortex_RH); ...
mean(data.subject_mean_LE_LCortex_LH); ...
mean(data.subject_mean_LE_LCortex_RH); ...
mean(data.subject_mean_RE_RCortex_LH); ...
mean(data.subject_mean_RE_RCortex_RH); ...
mean(data.subject_mean_LE_RCortex_LH); ...
mean(data.subject_mean_LE_RCortex_RH)], ...
                    'VariableNames', {'Condition', 'Mean'});

    % Display the table
    disp("Mean values of groups for power analysis")
    disp(results);
end
