function calculateANOVAMotor()
    params = setAnalysisParams();
    nsubs = numel(params.subjects)
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_motor_mean.mat"));
    anova_data_LCortext = [cat(2, data.subject_mean_LH_LCortex, data.subject_mean_RH_LCortex)', cat(2, data.subject_mean_LH_LCortex, data.subject_mean_RH_LCortex)']

    anova_data_RCortext = [cat(2, data.subject_mean_LH_RCortex, data.subject_mean_RH_RCortex)', cat(2, data.subject_mean_LH_RCortex, data.subject_mean_RH_RCortex)']

    [~,~,stats_LCortex] = anova2(anova_data_LCortext,nsubs);
    [~,~,stats_RCortex] = anova2(anova_data_RCortext,nsubs);

    c_L = multcompare(stats_LCortex);
    c_R = multcompare(stats_RCortex);
end
