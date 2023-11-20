function timeCourseAuditory()
    computeTimeCourseAuditory();
    computeMeanTimeCourseAuditory();
    for cortex = ["LCortex", "RCortex"]
        plotTimeCourseAuditory(cortex)
    end
end
