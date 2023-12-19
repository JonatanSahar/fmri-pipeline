function calculateANOVA()
    params = setAnalysisParams();
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_mean.mat"));
    anova_data_LCortext = [data.subject_mean_LE_LCortex_LH', data.subject_mean_LE_LCortex_RH', data.subject_mean_RE_LCortex_LH', data.subject_mean_RE_LCortex_RH'];
    anova_data_RCortext = [data.subject_mean_LE_RCortex_LH', data.subject_mean_LE_RCortex_RH', data.subject_mean_RE_RCortex_LH', data.subject_mean_RE_RCortex_RH']

    WithinDesign = table({'LE', 'LE', 'RE', 'RE'}', {'LH', 'RH', 'LH', 'RH'}', ...
                         'VariableNames', {'Ear', 'Hand'});

    tblL = array2table(anova_data_LCortext, 'VariableNames', {'LE_LH', 'LE_RH', 'RE_LH', 'RE_RH'});
    tblR = array2table(anova_data_RCortext, 'VariableNames', {'LE_LH', 'LE_RH', 'RE_LH', 'RE_RH'});

    rm = fitrm(tblR, 'LE_LH-RE_RH ~ 1', 'WithinDesign', WithinDesign);
    ranovatbl_LCortex = ranova(rm, 'WithinModel','Ear*Hand')

    rm = fitrm(tblR, 'LE_LH-RE_RH ~ 1', 'WithinDesign', WithinDesign);
    ranovatbl_RCortex = ranova(rm, 'WithinModel','Ear*Hand')
end
