function calculateANOVAMotor()
    params = setAnalysisParams();
    nsubs = numel(params.subjects)
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_motor_mean.mat"));
    anova_data_LCortext = [data.subject_mean_LH_LCortex', data.subject_mean_RH_LCortex', data.subject_mean_LH_RCortex', data.subject_mean_RH_RCortex']

    anova_data_RCortext = [data.subject_mean_LH_RCortex', data.subject_mean_RH_RCortex', data.subject_mean_LH_RCortex', data.subject_mean_RH_RCortex']

    WithinDesign = table({'LCortex', 'LCortex', 'RCortex', 'RCortex'}', {'LH', 'RH', 'LH', 'RH'}', ...
                         'VariableNames', {'Cortex', 'Hand'});

    tblL = array2table(anova_data_LCortext, 'VariableNames', {'LCortex_LH', 'LCortex_RH', 'RCortex_LH', 'RCortex_RH'});
    tblR = array2table(anova_data_RCortext, 'VariableNames', {'LCortex_LH', 'LCortex_RH', 'RCortex_LH', 'RCortex_RH'});

    rm = fitrm(tblR, 'LCortex_LH-RCortex_RH ~ 1', 'WithinDesign', WithinDesign);
    ranovatbl_LCortex = ranova(rm, 'WithinModel','Cortex*Hand')

    rm = fitrm(tblR, 'LCortex_LH-RCortex_RH ~ 1', 'WithinDesign', WithinDesign);
    ranovatbl_RCortex = ranova(rm, 'WithinModel','Cortex*Hand')
end
