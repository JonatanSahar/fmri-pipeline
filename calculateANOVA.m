function calculateANOVA()
    params = setAnalysisParams();
    nusbs = numel(params.subjects)
    data = load(fullfile(params.experimentDir, "time-course-results", "timeCourseSignificantVoxels", "time_course_mean.mat"));
    anova_data_LCortext = [cat(2, data.subject_mean_LE_LCortex_LH, data.subject_mean_LE_LCortex_RH)', cat(2, data.subject_mean_RE_LCortex_LH, data.subject_mean_RE_LCortex_RH)']

    anova_data_RCortext = [cat(2, data.subject_mean_LE_RCortex_LH, data.subject_mean_LE_RCortex_RH)', cat(2, data.subject_mean_RE_RCortex_LH, data.subject_mean_RE_RCortex_RH)']

    [~,~,stats_LCortex] = anova2(anova_data_LCortext,nsubs);
    [~,~,stats_RCortex] = anova2(anova_data_RCortext,nsubs);

    c_L = multcompare(stats_LCortex);
    c_R = multcompare(stats_RCortex);
end
